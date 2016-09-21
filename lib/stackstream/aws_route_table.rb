require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Route Table defined in the DSL
  class AwsRouteTable
    using Shared::Builder

    attr_accessor :named_object, :provider_id, :vpc, :tags

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_route_table if destroy_object?
      create_route_table if @provider_id.nil?
      modify_route_table
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
      content['aws_route_table'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_route_table', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_route_table' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_route_table'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(vpc).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_route_table
      result = connection.create_route_table(@vpc)

      @provider_id = result.data[:body]['routeTable'].first['routeTableId']
    end

    def modify_route_table
      connection.create_tags(@provider_id, @tags) unless Fog.mock?
    end

    def route_table_associations
      connection.route_tables.get(@provider_id).associations
    end

    def destroy_route_table
      route_table_associations.each do |route_table_association|
        connection.disassociate_route_table(
          route_table_association['routeTableAssociationId']
        )
      end

      connection.delete_route_table(@provider_id)

      sleep 1 until connection.route_tables.reload.get(@provider_id).nil?

      @provider_id = nil
    end
  end

  # Builds AwsRouteTable
  class AwsRouteTableClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def vpc(v)
      @vpc = v.provider_id
    end

    def tags(v)
      @tags = v.stringify
      @tags.store('Name', @named_object) if @tags['Name'].nil?
    end

    def build
      AwsRouteTable.new(
        named_object: @named_object,
        vpc: @vpc,
        tags: @tags
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_route_table(named_object, &block)
      object = Docile.dsl_eval(
        AwsRouteTableClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
