wrequire 'stackstream/aws_route_table_association'

extend Stackstream::Stack

AwsSubnet = Struct.new(:provider_id)
sb_object = AwsSubnet.new
sb_object.provider_id = 'test-id'

AwsRouteTable = Struct.new(:provider_id)
rtb_object = AwsRouteTable.new
rtb_object.provider_id = 'test-id'

aws_route_table_association 'my_route_table_association' do
  subnet sb_object
  route_table rtb_object
end

aws_route_table_association(my_route_table_association)

RSpec.describe Stackstream::AwsRouteTableAssociation do
  it 'comes back as an object' do
    expect(MyRouteTableAssociation).not_to be nil
  end
end
