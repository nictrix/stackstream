require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsRouteTableAssociation
    attr_accessor :provider_id, :subnet, :route_table, :tags

    def create_or_modify
      # Fog code here
      @provider_id = 'rtb-sdk23lss'
    end
  end

  # Builds classes based on AwsVpcSubnet
  class AwsRouteTableAssociationClassBuilder
    include Stackstream::Shared

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def subnet(v)
      @subnet = v.provider_id
      self
    end

    def route_table(v)
      @route_table = v.provider_id
      self
    end

    def build
      new_class = (Object.const_set classify(@named_object), Class.new(AwsRouteTableAssociation))
      class_object = new_class.new
      class_object.subnet = @subnet
      class_object.route_table = @route_table
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_route_table_association(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsRouteTableAssociationClassBuilder.new(named_object), &block
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
