require 'support/stackstream/aws_vpc_examples'
require 'stackstream/aws_route_table'

RSpec.shared_context '#aws_route_table' do
  include_context '#aws_vpc'

  let(:my_route_table) do
    extend Stackstream::Stack

    aws_route_table 'my_route_table' do
      vpc my_vpc

      tags(
        Environment: 'Integration'
      )
    end

    my_route_table
  end
end
