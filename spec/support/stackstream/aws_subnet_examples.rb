require 'support/stackstream/aws_vpc_examples'
require 'stackstream/aws_subnet'

RSpec.shared_context '#aws_subnet' do
  include_context '#aws_vpc'

  let(:my_subnet) do
    extend Stackstream::Stack

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
