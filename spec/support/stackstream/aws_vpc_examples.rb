require 'stackstream/aws_vpc'

RSpec.shared_context '#aws_vpc' do
  let(:my_vpc) do
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

    my_vpc
  end
end
