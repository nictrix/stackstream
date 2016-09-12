require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsVpc
    attr_accessor :provider_id, :cidr_block, :enable_dns_hostnames, :tags

    def create_or_modify
      # Fog code goes here
      @provider_id = 'vpc-3235sd2'
    end
  end

  # Builds classes based on AwsVpc
  class AwsVpcClassBuilder
    include Stackstream::Shared

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def cidr_block(v)
      @cidr_block = v
      self
    end

    def enable_dns_hostnames(v)
      @enable_dns_hostnames = v
      self
    end

    def tags(v)
      @tags = v
      self
    end

    def build
      new_class = (Object.const_set classify(@named_object), Class.new(AwsVpc))
      class_object = new_class.new
      class_object.cidr_block = @cidr_block
      class_object.enable_dns_hostnames = @enable_dns_hostnames
      class_object.tags = @tags
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_vpc(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsVpcClassBuilder.new(named_object), &block
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
