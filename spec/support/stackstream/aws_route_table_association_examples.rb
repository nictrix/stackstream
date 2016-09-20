require 'support/stackstream/aws_subnet_examples'
require 'support/stackstream/aws_route_table_examples'
require 'stackstream/aws_route_table_association'

RSpec.shared_context '#aws_route_table_association' do
  include_context '#aws_subnet'
  include_context '#aws_route_table'

  let(:my_route_table_association) do
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

    aws_route_table_association 'my_route_table_association' do
      subnet my_subnet
      route_table my_route_table
    end

    my_route_table_association
  end
end
