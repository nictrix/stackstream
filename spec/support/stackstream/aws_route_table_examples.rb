require 'stackstream/aws_vpc'
require 'stackstream/aws_route_table'

RSpec.shared_context '#aws_route_table' do
  let(:my_route_table) do
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

    aws_route_table 'my_route_table' do
      vpc my_vpc

      tags(
        Environment: 'Integration'
      )
    end

    my_route_table
  end
end
