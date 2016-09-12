require 'stackstream/aws_subnet'

extend Stackstream::Stack

AwsVpc = Struct.new(:provider_id)
vpc_object = AwsVpc.new
vpc_object.provider_id = 'test-id'

aws_subnet 'my_subnet' do
  vpc my_vpc

  cidr_block '192.168.1.0/24'
  availability_zone 'us-east-1c'
  map_public_ip_on_launch true

  tags(
    Name: 'my_subnet'
  )
end

aws_subnet(my_subnet)

RSpec.describe Stackstream::AwsSubnet do
  it 'comes back as an object' do
    expect(MySubnet).not_to be nil
  end
end
