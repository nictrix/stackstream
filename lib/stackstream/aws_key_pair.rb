require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsKeyPair
    attr_accessor :provider_id, :key_name, :public_key

    def create_or_modify
      # Fog code here
      @provider_id = 'id_rsa'
    end
  end

  # Builds classes based on AwsVpcSubnet
  class AwsKeyPairClassBuilder
    include Stackstream::Shared

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
      new_class = (Object.const_set classify(@named_object), Class.new(AwsKeyPair))
      class_object = new_class.new
      class_object.key_name = @key_name
      class_object.public_key = @public_key
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_key_pair(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsKeyPairClassBuilder.new(named_object), &block
        ).build

        define_method(named_object) do
          instance_variable_get("@__#{named_object}")
        end
        instance_variable_set("@__#{named_object}", object)
      else
        named_object
      end
    end
  end
end
