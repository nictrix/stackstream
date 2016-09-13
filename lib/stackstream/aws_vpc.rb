require_relative 'shared'

module Stackstream
  # Base class for VPCs defined in the DSL
  class AwsVpc
    attr_accessor :provider_id, :cidr_block, :enable_dns_hostnames, :tags

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def create_or_modify
      # Fog code goes here
      @provider_id = 'vpc-3235sd2'
    end
  end

  # Builds classes based on AwsVpc
  class AwsVpcClassBuilder
    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def cidr_block(v)
      @cidr_block = v
    end

    def enable_dns_hostnames(v)
      @enable_dns_hostnames = v
    end

    def tags(v)
      @tags = v
    end

    def build
      AwsVpc.new(
        cidr_block: @cidr_block,
        enable_dns_hostnames: @enable_dns_hostnames,
        tags: @tags
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_vpc(named_object, &block)
      object = Docile.dsl_eval(
        AwsVpcClassBuilder.new(named_object), &block
      ).build

      object.create_or_modify

      define_local_method(named_object, object)
    end
  end
end
