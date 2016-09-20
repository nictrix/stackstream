require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Internet Gateways defined in the DSL
  class AwsInternetGateway
    using Shared::Builder

    attr_accessor :name, :provider_id, :vpc, :tags

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_igw if destroy_object?

      if @provider_id.nil?
        create_igw
        attach_igw
      end

      modify_igw
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
      content['aws_internet_gateway'].store(@name, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_internet_gateway', @name.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_internet_gateway' => {
          @name.to_s => {}
        }
      }
    end

    def current_object
      state['aws_internet_gateway'][@name]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(vpc).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_igw
      result = connection.create_internet_gateway

      @provider_id = result.data[:body]['internetGatewaySet']
                           .first['internetGatewayId']
    end

    def attach_igw
      connection.attach_internet_gateway(@provider_id, @vpc)
    end

    def modify_igw
      connection.create_tags(@provider_id, @tags)
    end

    def destroy_igw
      connection.detach_internet_gateway(@provider_id, @vpc)
      connection.delete_internet_gateway(@provider_id)

      sleep 1 until connection.internet_gateways.reload.get(@provider_id).nil?

      @provider_id = nil
    end
  end

  # Builds AwsInternetGateway
  class AwsInternetGatewayClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def vpc(v)
      @vpc = v.provider_id
    end

    def tags(v)
      @tags = v.stringify
      @tags.store('Name', @named_object) if @tags['Name'].nil?
    end

    def build
      AwsInternetGateway.new(
        name: @named_object,
        vpc: @vpc,
        tags: @tags
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_internet_gateway(named_object, &block)
      object = Docile.dsl_eval(
        AwsInternetGatewayClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
