require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Subnets defined in the DSL
  class AwsAmiFromInstance
    using Shared::Builder

    attr_accessor :named_object, :provider_id, :source_instance_id, :name,
                  :description, :snapshot_without_reboot

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_ami_from_instance if destroy_object?
      create_ami_from_instance if @provider_id.nil?
      modify_ami_from_instance
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
      content['aws_ami_from_instance'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_ami_from_instance', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_ami_from_instance' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_ami_from_instance'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(source_instance_id name snapshot_without_reboot).each do |property|
        next if current_object[property].nil?
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_ami_from_instance
      response = connection.create_image(
        @source_instance_id, @name, @description, @snapshot_without_reboot
      )
      @provider_id = response.data[:body]['imageId']

      until connection.images('ImageId' => [@provider_id])
                      .reload.first.state == 'available'
        sleep 1
      end
    end

    def modify_ami_from_instance
      connection.modify_image_attribute(
        @provider_id, 'Description.Value' => @description
      )
    end

    def destroy_ami_from_instance
      response = connection.deregister_image(@provider_id)

      @provider_id = nil if response.data[:body]['return'] == 'true'
    end
  end

  # Builds AwsAmiFromInstance
  class AwsAmiFromInstanceClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def name(v)
      @name = v
    end

    def source_instance_id(v)
      @source_instance_id = v
    end

    def description(v)
      @description = v
    end

    def snapshot_without_reboot(v)
      @snapshot_without_reboot = v
    end

    def build
      AwsAmiFromInstance.new(
        named_object: @named_object,
        name: @name,
        source_instance_id: @source_instance_id,
        description: @description,
        snapshot_without_reboot: @snapshot_without_reboot
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_ami_from_instance(named_object, &block)
      object = Docile.dsl_eval(
        AwsAmiFromInstanceClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
