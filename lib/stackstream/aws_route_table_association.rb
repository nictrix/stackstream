require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Route Table Associations defined in the DSL
  class AwsRouteTableAssociation
    using Shared::Builder

    attr_accessor :named_object, :provider_id, :subnet, :route_table

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_route_table_association if destroy_object?
      create_route_table_association if @provider_id.nil?
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
      content['aws_route_table_association'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_route_table_association', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_route_table_association' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_route_table_association'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(subnet route_table).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def create_route_table_association
      result = connection.associate_route_table(@route_table, @subnet)
      @provider_id = result.data[:body]['associationId']
    end

    def destroy_route_table_association
      connection.disassociate_route_table(@provider_id)
      @provider_id = nil
    end
  end

  # Builds AwsRouteTableAssociation
  class AwsRouteTableAssociationClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def subnet(v)
      @subnet = v.provider_id
    end

    def route_table(v)
      @route_table = v.provider_id
    end

    def build
      AwsRouteTableAssociation.new(
        named_object: @named_object,
        subnet: @subnet,
        route_table: @route_table
      )
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_route_table_association(named_object, &block)
      object = Docile.dsl_eval(
        AwsRouteTableAssociationClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
