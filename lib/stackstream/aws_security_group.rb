require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Security Groups defined in the DSL
  class AwsSecurityGroup
    using Shared::Builder

    attr_accessor :named_object, :name, :provider_id, :description, :vpc, :tags

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_security_group if destroy_object?
      create_security_group if @provider_id.nil?
      modify_security_group
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
      content['aws_security_group'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_security_group', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_security_group' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_security_group'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(name description vpc).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_security_group
      result = connection.create_security_group(@name, @description, @vpc)

      @provider_id = result.data[:body]['groupId']
    end

    def modify_security_group
      connection.create_tags(@provider_id, @tags) unless Fog.mock?
    end

    def destroy_security_group
      connection.delete_security_group(nil, @provider_id)

      sleep 1 until connection.security_groups.reload.get(@provider_id).nil?

      @provider_id = nil
    end
  end

  # Builds AwsSecurityGroup
  class AwsSecurityGroupClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def name(v)
      @name = v
    end

    def description(v)
      @description = v
    end

    def vpc(v)
      @vpc = v.provider_id
    end

    def tags(v)
      @tags = v.stringify
      @tags.store('Name', @named_object) if @tags['Name'].nil?
    end

    def build
      AwsSecurityGroup.new(
        named_object: @named_object,
        name: @name,
        description: @description,
        vpc: @vpc,
        tags: @tags
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_security_group(named_object, &block)
      object = Docile.dsl_eval(
        AwsSecurityGroupClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
