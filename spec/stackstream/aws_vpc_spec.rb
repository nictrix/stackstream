require 'stackstream/aws_vpc'

extend Stackstream::Stack

aws_vpc 'my_vpc' do
  cidr_block '192.168.0.0/16'
  enable_dns_hostnames true
  tags(
    Name: 'my_vpc'
  )
end

aws_vpc(my_vpc)

RSpec.describe Stackstream::AwsVpc do
  it 'comes back as an object' do
    expect(MyVpc).not_to be nil
  end
end
