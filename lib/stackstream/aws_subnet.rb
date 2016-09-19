require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Subnets defined in the DSL
  class AwsSubnet
    using Shared::Builder

    attr_accessor :name, :provider_id, :vpc, :cidr_block, :availability_zone,
                              :map_public_ip_on_launch, :tags

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_subnet if destroy_object?
      create_subnet if @provider_id.nil?
      modify_subnet
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
      content['aws_subnet'].store(@name, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify
      
      unless content.dig('aws_subnet', @name.to_s)
        content.merge!(state_content_defaults) 
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_subnet' => {
          @name.to_s => {}
        }
      }
    end

    def current_object
      state['aws_subnet'][@name]
    end

    def new_object
      to_hash
    end


    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(vpc cidr_block availability_zone).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_subnet
      subnet = connection.create_subnet(@vpc, @cidr_block, 'AvailabilityZone' =>
        @availability_zone)
      @provider_id = subnet.data[:body]['subnet']['subnetId']
      
      until connection.subnets.reload.get(@provider_id).state == "available" do
        sleep 1
      end
    end


    def modify_subnet
      connection.modify_subnet_attribute(@provider_id, 'MapPublicIpOnLaunch' =>
        @map_public_ip_on_launch)

      # not implemented in fog/aws mocks
      connection.create_tags(@provider_id, @tags) unless Fog.mock? 
    end

    def destroy_subnet
      connection.delete_subnet(@provider_id)
      # TODO: delete all the other objects within the subnet

      sleep 1 until connection.subnets.reload.get(@provider_id).nil?

      @provider_id = nil
    end
  end

  # Builds AwsSubnet
  class AwsSubnetClassBuilder
    using Shared::Builder

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
      @tags = v.stringify
      @tags.store('Name',@named_object) if @tags['Name'].nil?
    end

    def build
      AwsSubnet.new(
        name: @named_object,
        cidr_block: @cidr_block,
        vpc: @vpc,
        availability_zone: @availability_zone,
        map_public_ip_on_launch: @map_public_ip_on_launch,
        tags: @tags
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_subnet(named_object, &block)
      object = Docile.dsl_eval(
        AwsSubnetClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
