require 'stackstream/aws_internet_gateway'

extend Stackstream::Stack

AwsVpc = Struct.new(:provider_id)
vpc_object = AwsVpc.new
vpc_object.provider_id = 'test-id'

aws_internet_gateway 'my_internet_gateway' do
  vpc vpc_object

  tags(
    Name: 'my_internet_gateway'
  )
end

aws_internet_gateway(my_internet_gateway)

RSpec.describe Stackstream::AwsInternetGateway do
  it 'comes back as an object' do
    expect(MyInternetGateway).not_to be nil
  end
end
