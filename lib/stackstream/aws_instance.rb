require_relative 'shared'
require 'fog/aws'
require 'json'

module Stackstream
  # Base class for Instances defined in the DSL
  class AwsInstance
    using Shared::Builder

    attr_accessor :named_object, :ami, :instance_type, :key_name, :tags,
                  :vpc_security_groups, :subnet, :provider_id,
                  :kernel, :disable_api_termination,
                  :instance_initiated_shutdown_behavior, :user_data,
                  :source_dest_check, :root_block_device,
                  :associate_public_ip_address, :tenancy,
                  :placement_availability_zone, :placement_group,
                  :monitoring, :ebs_optimized
                  # iam_instance_profile ?

    def initialize(**args)
      args.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def transform
      destroy_instance if destroy_object?
      create_instance if @provider_id.nil?
      modify_instance
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
      content['aws_instance'].store(@named_object, new_object)
      File.write('formation.state', JSON.pretty_generate(content))
    end

    def state
      content = JSON.parse(File.read('formation.state')).stringify

      unless content.dig('aws_instance', @named_object.to_s)
        content.merge!(state_content_defaults)
      end

      content
    rescue
      state_content_defaults
    end

    def state_content_defaults
      {
        'aws_instance' => {
          @named_object.to_s => {}
        }
      }
    end

    def current_object
      state['aws_instance'][@named_object]
    end

    def new_object
      to_hash
    end

    def destroy_object?
      return false if current_object['provider_id'].nil?

      %w(ami subnet key_name).each do |property|
        return true if current_object[property] != new_object[property]
      end

      false
    end

    def formatted_block_device_mapping
      [formatted_root_block_device, formatted_ephemeral_block_device].flatten!
    end

    def image_attributes
      connection.describe_images(
        'ImageId' => [@ami]
      ).data[:body]['imagesSet'].first
    end

    def root_block_device_from_image
      image_attributes['blockDeviceMapping'].select do |bdm|
        bdm['deviceName'] == image_attributes['rootDeviceName']
      end.first
    end

    def root_block_device_stringify
      @root_block_device.stringify
    end

    def root_block_device_volume_size
      root_block_device_stringify['volume_size'] || 
      root_block_device_from_image['volumeSize']
    end

    def root_block_device_delete_on_termination
      root_block_device_stringify['delete_on_termination'] ||
      root_block_device_from_image['deleteOnTermination']
    end

    def root_block_device_volume_type
      root_block_device_stringify['volume_type'] ||
      root_block_device_from_image['volumeType']
    end

    def root_block_device_hash
      {
        'device_name' => root_block_device_from_image['deviceName'],
        'snapshot' => root_block_device_from_image['snapshotId'],
        'volume_size' => root_block_device_volume_size,
        'delete_on_termination' => root_block_device_delete_on_termination,
        'volume_type' => root_block_device_volume_type,
        'iops' => root_block_device_stringify['iops']
      }
    end

    def formatted_root_block_device
      {
        'DeviceName' => root_block_device_hash['device_name'],
        'VirtualName' => root_block_device_hash['virtual_name'],
        'Ebs.SnapshotId' => root_block_device_hash['snapshot'],
        'Ebs.VolumeSize' => root_block_device_hash['volume_size'],
        'Ebs.DeleteOnTermination' =>
        root_block_device_hash['delete_on_termination'],
        'Ebs.VolumeType' => root_block_device_hash['volume_type'],
        'Ebs.Iops' => root_block_device_hash['iops']
      }
    end

    def ephemeral_block_device_count
      connection.flavors.get(@instance_type).instance_store_volumes
    end

    def formatted_ephemeral_block_device
      devices = []
      (0..(ephemeral_block_device_count - 1)).each do |device_number|
        devices << {
          'DeviceName' => "/dev/sd#{('b'..'z').to_a[device_number]}",
          'VirtualName' => "ephemeral#{device_number}"
        }
      end

      devices
    end

    def formatted_network_interfaces
      [{ 'DeviceIndex' => 0, 'SubnetId' => @subnet,
         'Description' => 'Primary Network Interface',
         'PrivateIpAddress' => @private_ip, 'DeleteOnTermination' => true,
         'PrivateIpAddresses.Primary' => true,
         'AssociatePublicIpAddress' => @associate_public_ip_address }]
    end

    def create_instance
      options = {
        'Placement.AvailabilityZone' => @placement_availability_zone,
        'Placement.GroupName' => @placement_group,
        'Placement.Tenancy' => @tenancy,
        'BlockDeviceMapping' => formatted_block_device_mapping,
        'NetworkInterfaces' => formatted_network_interfaces,
        'DisableApiTermination' => @disable_api_termination,
        'SecurityGroupId' => @vpc_security_groups,
        'InstanceInitiatedShutdownBehaviour' =>
        @instance_initiated_shutdown_behavior,
        'InstanceType' => @instance_type,
        'KernelId' => @kernel,
        'KeyName' => @key_name,
        'Monitoring.Enabled' => @monitoring,
        'PrivateIpAddress' => @private_ip,
        'SubnetId' => @subnet,
        'UserData' => @user_data,
        'EbsOptimized' => @ebs_optimized
      }
      result = connection.run_instances(@ami, 1, 1, options)

      @provider_id = result.data[:body]['instancesSet'].first['instanceId']
    end

    def modify_instance
      connection.modify_instance_attribute(
        @provider_id,
        'InstanceType' => @instance_type, 'Kernel' => @kernel,
        'DisableApiTermination' => @disable_api_termination,
        'InstanceInitiatedShutdownBehavior' =>
        @instance_initiated_shutdown_behavior, 'UserData' => @user_data,
        'SourceDestCheck' => @source_dest_check,
        'GroupId' => @vpc_security_groups
      ) unless Fog.mock?
      connection.create_tags(@provider_id, @tags)
    end

    def destroy_instance
      connection.terminate_instances([@provider_id])

      sleep 1 until connection.describe_instances('instance-id' =>
        [@provider_id]).data[:body]['instancesSet'].nil?

      @provider_id = nil
    end
  end

  # Builds AwsInstance
  class AwsInstanceClassBuilder
    using Shared::Builder

    def initialize(named_object)
      instance_variable_set('@named_object', named_object)
      yield self if block_given?
    end

    def ami(v)
      @ami = v
    end

    def kernel(v)
      @kernel = v
    end

    def instance_type(v)
      @instance_type = v
    end

    def subnet(v)
      @subnet = v.provider_id
    end

    def user_data(v)
      @user_data = v
    end

    def vpc_security_groups(v)
      @vpc_security_groups = v.collect(&:provider_id)
    end

    def tenancy(v)
      @tenancy = v
    end

    def key_name(v)
      @key_name = v.key_name
    end

    def disable_api_termination(v)
      @disable_api_termination = v
    end

    def source_dest_check(v)
      @source_dest_check = v
    end

    def monitoring(v)
      @monitoring = v
    end

    def root_block_device(v)
      @root_block_device = v
    end

    def ebs_optimized(v)
      @ebs_optimized = v
    end

    def placement_group(v)
      @placement_group = v
    end

    def associate_public_ip_address(v)
      @associate_public_ip_address = v
    end

    def placement_availability_zone(v)
      @placement_availability_zone = v
    end

    def instance_initiated_shutdown_behavior(v)
      @instance_initiated_shutdown_behavior = v
    end

    def tags(v)
      @tags = v.stringify
      @tags.store('Name', @named_object) if @tags['Name'].nil?
    end

    def build
      AwsInstance.new(named_object: @named_object, ami: @ami, kernel: @kernel,
                      instance_type: @instance_type, subnet: @subnet,
                      user_data: @user_data, tenancy: @tenancy, tags: @tags,
                      vpc_security_groups: @vpc_security_groups,
                      key_name: @key_name, monitoring: @monitoring,
                      disable_api_termination: @disable_api_termination,
                      source_dest_check: @source_dest_check,
                      root_block_device: @root_block_device,
                      ebs_optimized: @ebs_optimized,
                      placement_group: @placement_group,
                      associate_public_ip_address: @associate_public_ip_address,
                      placement_availability_zone: @placement_availability_zone,
                      instance_initiated_shutdown_behavior:
                      @instance_initiated_shutdown_behavior)
    end
  end

  # Runtime methods to inject when parsing the DSL
  module Stack
    include Stackstream::Stack::Shared

    def aws_instance(named_object, &block)
      object = Docile.dsl_eval(
        AwsInstanceClassBuilder.new(named_object), &block
      ).build

      object.transform

      define_local_method(named_object, object)
    end
  end
end
