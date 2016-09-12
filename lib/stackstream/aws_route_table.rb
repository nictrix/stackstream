require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsRouteTable
    attr_accessor :provider_id, :vpc, :route, :tags

    def create_or_modify
      # Fog code here
      @provider_id = 'rtb-sdk23lss'
    end
  end

  # Builds classes based on AwsVpcSubnet
  class AwsRouteTableClassBuilder
    include Stackstream::Shared

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def vpc(v)
      @vpc = v.provider_id
      self
    end

    def route(v)
      puts v.inspect
      @route = v
      self
    end

    def tags(v)
      @tags = v
      self
    end

    def build
      new_class = (Object.const_set classify(@named_object), Class.new(AwsRouteTable))
      class_object = new_class.new
      class_object.vpc = @vpc
      class_object.tags = @tags
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_route_table(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsRouteTableClassBuilder.new(named_object), &block
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
