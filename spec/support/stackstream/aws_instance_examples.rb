require 'support/stackstream/aws_subnet_examples'
require 'support/stackstream/aws_key_pair_examples'
require 'support/stackstream/aws_security_group_examples'
require 'stackstream/aws_instance'

RSpec.shared_context '#aws_instance' do
  include_context '#aws_subnet'
  include_context '#aws_key_pair'
  include_context '#aws_security_group'

  let(:my_instance) do
    extend Stackstream::Stack

    aws_vpc 'my_vpc' do
      cidr_block '192.168.0.0/16'
      instance_tenancy 'default'
      enable_dns_support true
      enable_dns_hostnames true
      tags(
        Environment: 'Integration'
      )
    end

    aws_security_group 'my_security_group' do
      name 'self-security-group'
      description 'my security group'
      vpc my_vpc

      tags(
        Environment: 'Integration'
      )
    end

    aws_instance 'my_instance' do
      ami 'ami-13be557e'
      instance_type 'm3.xlarge'
      key_name my_key_pair
      vpc_security_groups [
        my_security_group
      ]
      subnet my_subnet

      root_block_device(
        'volume_size' => 10,
        'delete_on_termination' => false,
        'volume_type' => 'io1',
        'iops' => 1000
      )

      tags(
        Environment: 'Integration'
      )
    end

    my_instance
  end
end
