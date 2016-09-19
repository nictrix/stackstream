require 'stackstream/aws_vpc'
require 'stackstream/aws_subnet'

RSpec.shared_context '#aws_subnet' do
  let(:my_subnet) do
    extend Stackstream::Stack

    aws_vpc 'my_vpc' do
      cidr_block '192.168.0.0/16'
      instance_tenancy false
      enable_dns_support true
      enable_dns_hostnames true
      tags(
        Environment: 'Integration'
      )
    end

    aws_subnet 'my_subnet' do
      vpc my_vpc

      cidr_block '192.168.1.0/24'
      availability_zone 'us-east-1c'
      map_public_ip_on_launch true

      tags(
        Environment: 'Integration'
      )
    end

    my_subnet
  end
end
