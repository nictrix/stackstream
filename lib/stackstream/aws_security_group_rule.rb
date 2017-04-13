require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Security Group Rules defined in the DSL
  class AwsSecurityGroupRule
    using Shared::Builder

    attr_accessor :named_object, :type, :from_port, :to_port,
                  :protocol, :cidr_blocks, :prefix_lists,
                  :security_group, :source_security_groups

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_security_group_rule if destroy_object?
      create_security_group_rule
      update_state
      self
    end

    private

    def connection
      Fog::Compute.new provider: 'AWS', region: 'us-west-2',
                       aws_access_key_id: '', aws_secret_access_key: ''
    end

    def update_state
      content = state.dup
      content['aws_security_group_rule'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_security_group_rule', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_security_group_rule' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_security_group_rule'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object == {}

      %w(type from_port to_port protocol cidr_blocks prefix_lists
         security_group source_security_groups).each do |property|
        next if current_object[property].nil?
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def formatted_cidr_blocks
      blocks = []
      return blocks if @cidr_blocks.nil?

      @cidr_blocks.each do |cidr_block|
        blocks << { 'CidrIp' => cidr_block }
      end

      blocks
    end

    def formatted_source_security_groups
      groups = []
      return groups if @source_security_groups.nil?

      @source_security_groups.each do |source_security_group|
        name = connection.security_groups.get_by_id(source_security_group)
        groups << { 'GroupName' => name, 'groupId' => source_security_group }
      end

      groups
    end

    def create_security_group_rule
      permissions = { 'GroupId' => @security_group, 'IpPermissions' => [{
        'IpProtocol' => @protocol, 'FromPort' => @from_port,
        'ToPort' => @to_port, 'IpRanges' => formatted_cidr_blocks,
        'Groups' => formatted_source_security_groups
      }] }
      if @type == 'ingress'
        connection.authorize_security_group_ingress(permissions)
      else
        connection.authorize_security_group_egress(permissions)
      end
    end

    def destroy_security_group_rule
      permissions = { 'GroupId' => @security_group, 'IpPermissions' => [{
        'IpProtocol' => @protocol, 'FromPort' => @from_port,
        'ToPort' => @to_port, 'IpRanges' => formatted_cidr_blocks,
        'Groups' => formatted_source_security_groups
      }] }
      if @type == 'ingress'
        connection.revoke_security_group_ingress(permissions)
      else
        connection.revoke_security_group_egress(permissions)
      end
    end
  end

  # Builds AwsSecurityGroupRule
  class AwsSecurityGroupRuleClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def type(v)
      @type = v
    end

    def from_port(v)
      @from_port = v
    end

    def to_port(v)
      @to_port = v
    end

    def protocol(v)
      @protocol = v
    end

    def cidr_blocks(v)
      @cidr_blocks = v
    end

    def prefix_lists(v)
      @prefix_lists = v
    end

    def security_group(v)
      @security_group = v.provider_id
    end

    def source_security_groups(v)
      @source_security_groups = v.collect(&:provider_id)
    end

    def build
      AwsSecurityGroupRule.new(
        named_object: @named_object, type: @type,
        from_port: @from_port, to_port: @to_port,
        protocol: @protocol, cidr_blocks: @cidr_blocks,
        prefix_lists: @prefix_lists, security_group: @security_group,
        source_security_groups: @source_security_groups
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_security_group_rule(named_object, &block)
      object = Docile.dsl_eval(
        AwsSecurityGroupRuleClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
