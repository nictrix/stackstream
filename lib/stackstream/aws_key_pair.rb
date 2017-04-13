require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsKeyPair
    using Shared::Builder

    attr_accessor :named_object, :key_name, :public_key

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_key_pair if destroy_object?
      create_key_pair

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
      content['aws_key_pair'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_key_pair', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_key_pair' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_key_pair'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object == {}

      %w(key_name public_key).each do |property|
        next if current_object[property].nil?
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_key_pair
      if @public_key.nil?
        connection.create_key_pair(@key_name)
      else
        connection.import_key_pair(@key_name, @public_key)
      end
    end

    def destroy_key_pair
      connection.delete_key_pair(@key_name)
    end
  end

  # Builds AwsKeyPair
  class AwsKeyPairClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def key_name(v)
      @key_name = v
    end

    def public_key(v)
      @public_key = v
    end

    def build
      AwsKeyPair.new(
        named_object: @named_object,
        key_name: @key_name,
        public_key: @public_key
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_key_pair(named_object, &block)
      object = Docile.dsl_eval(
        AwsKeyPairClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
