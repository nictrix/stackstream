require 'stackstream/shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsSubnet
    attr_accessor :provider_id, :vpc, :cidr_block, :availability_zone,
                  :map_public_ip_on_launch, :tags

    def create_or_modify
      # Fog code here
      @provider_id = 'subnet-sbd238hs'
    end
  end

  # Builds classes based on AwsVpcSubnet
  class AwsSubnetClassBuilder
    include Stackstream::Shared

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def vpc(v)
      @vpc = v.provider_id
    end

    def cidr_block(v)
      @cidr_block = v
    end

    def availability_zone(v)
      @availability_zone = v
    end

    def map_public_ip_on_launch(v)
      @map_public_ip_on_launch = v
    end

    def tags(v)
      @tags = v
    end

    def build
      new_class = (Object.const_set classify(@named_object), Class.new(AwsSubnet))
      class_object = new_class.new
      class_object.vpc = @vpc
      class_object.cidr_block = @cidr_block
      class_object.availability_zone = @availability_zone
      class_object.map_public_ip_on_launch = @map_public_ip_on_launch
      class_object.tags = @tags
      class_object.create_or_modify

      class_object
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    def aws_subnet(named_object = nil, &block)
      if block_given?
        object = Docile.dsl_eval(
          AwsSubnetClassBuilder.new(named_object), &block
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
