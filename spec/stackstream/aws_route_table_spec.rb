require 'stackstream/aws_route_table'

extend Stackstream::Stack

AwsVpc = Struct.new(:provider_id)
vpc_object = AwsVpc.new
vpc_object.provider_id = 'test-id'

AwsInternetGateway = Struct.new(:provider_id)
igw_object = AwsInternetGateway.new
igw_object.provider_id = 'test-id'

aws_route_table 'my_route_table' do
  vpc vpc_object

  route(
    cidr_block: '0.0.0.0/0',
    gateway_id: igw_object
  )

  tags(
    Name: 'my_route_table'
  )
end

aws_route_table(my_route_table)

RSpec.describe Stackstream::AwsRouteTable do
  it 'comes back as an object' do
    expect(MyRouteTable).not_to be nil
  end
end
