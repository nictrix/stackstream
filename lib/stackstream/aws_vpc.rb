require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsVpc
    using Shared::Builder

    attr_accessor :named_object, :provider_id, :cidr_block, :instance_tenancy,
                  :enable_dns_support, :enable_dns_hostnames, :tags

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_vpc if destroy_object?
      create_vpc if @provider_id.nil?
      modify_vpc
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
      content['aws_vpc'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify
      
      unless content.dig('aws_vpc', @named_object.to_s)
        content.merge!(state_content_defaults) 
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_vpc' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_vpc'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(cidr_block instance_tenancy).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_vpc
      vpc = connection.create_vpc(@cidr_block,
                                  'InstanceTenancy' => @instance_tenancy)

      @provider_id = vpc.data[:body]['vpcSet'].first['vpcId']

      sleep 1 until \
      connection.vpcs.reload.get(@provider_id).state == 'available'
    end

    def modify_vpc
      connection.modify_vpc_attribute(@provider_id,
                                      'EnableDnsSupport.Value' =>
                                      @enable_dns_support)
      connection.modify_vpc_attribute(@provider_id,
                                      'EnableDnsHostnames.Value' =>
                                      @enable_dns_hostnames)
      connection.create_tags(@provider_id, @tags)
    end

    def destroy_vpc
      connection.delete_vpc(@provider_id)
      # TODO: delete all the other objects within the vpc
      #               except default route and default security group

      sleep 1 until connection.vpcs.reload.get(@provider_id).nil?

      @provider_id = nil
    end
  end

  # Builds AwsVpc
  class AwsVpcClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def cidr_block(v)
      @cidr_block = v
    end

    def enable_dns_hostnames(v)
      @enable_dns_hostnames = v || true
    end

    def enable_dns_support(v)
      @enable_dns_support = v || true
    end

    def instance_tenancy(v)
      @instance_tenancy = v || 'default'
    end

    def tags(v)
      @tags = v.stringify
      @tags.store('Name', @named_object) if @tags['Name'].nil?
    end

    def build
      AwsVpc.new(
        named_object: @named_object,
        cidr_block: @cidr_block,
        instance_tenancy: @instance_tenancy,
        enable_dns_support: @enable_dns_support,
        enable_dns_hostnames: @enable_dns_hostnames,
        tags: @tags
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_vpc(named_object, &block)
      object = Docile.dsl_eval(
        AwsVpcClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
