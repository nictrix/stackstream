require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsInstance
    attr_accessor :provider_id, :ami, :instance_type, :key_name,
                  :vpc_security_group_ids, :subnet_id, :tags

    def create_or_modify
      # Fog code here
      @provider_id = 'i-32nsd923'
    end
  end

  # Builds classes based on AwsVpcSubnet
  class AwsInstanceClassBuilder
    include Stackstream::Shared

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def ami(v)
      @ami = v
      self
    end

    def instance_type(v)
      @instance_type = v
      self
    end

    def key_name(v)
      @key_name = v
      self
    end

    def vpc_security_group_ids(v)
      @vpc_security_group_ids = v
      self
    end

    def subnet_id(v)
      @subnet_id = v
      self
    end

    def tags(v)
      @tags = v
      self
    end

    def build
      new_class = (Object.const_set classify(@named_object), Class.new(AwsInstance))
      class_object = new_class.new
      class_object.ami = @ami
      class_object.instance_type = @instance_type
      class_object.key_name = @key_name
      class_object.vpc_security_group_ids = @vpc_security_group_ids
      class_object.subnet_id = @subnet_id
      class_object.tags = @tags
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_instance(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsInstanceClassBuilder.new(named_object), &block
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
