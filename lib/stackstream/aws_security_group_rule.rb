require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsSecurityGroupRule
    attr_accessor :provider_id, :type, :from_port, :to_port, :protocol,
                  :cidr_blocks, :security_group

    def create_or_modify
      # Fog code here
      @provider_id = 'rtb-sdk23lss'
    end
  end

  # Builds classes based on AwsVpcSubnet
  class AwsSecurityGroupRuleClassBuilder
    include Stackstream::Shared

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

    def security_group(v)
      @security_group = v.provider_id
    end

    def build
      new_class = (Object.const_set classify(@named_object), Class.new(AwsSecurityGroupRule))
      class_object = new_class.new
      class_object.type = @type
      class_object.from_port = @from_port
      class_object.to_port = @to_port
      class_object.protocol = @protocol
      class_object.cidr_blocks = @cidr_blocks
      class_object.security_group = @security_group
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_security_group_rule(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsSecurityGroupRuleClassBuilder.new(named_object), &block
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
