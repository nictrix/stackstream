require 'stackstream/aws_vpc'
require 'stackstream/aws_internet_gateway'

RSpec.shared_context '#aws_internet_gateway' do
  let(:my_internet_gateway) do
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

    aws_internet_gateway 'my_internet_gateway' do
      vpc my_vpc

      tags(
        Environment: 'Integration'
      )
    end

    my_internet_gateway
  end
end
