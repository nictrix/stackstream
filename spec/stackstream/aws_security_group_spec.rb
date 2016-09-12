require 'stackstream/aws_security_group'

extend Stackstream::Stack

AwsVpc = Struct.new(:provider_id)
vpc_object = AwsVpc.new
vpc_object.provider_id = 'test-id'

aws_security_group 'my_security_group' do
  name 'my_security_group'
  description 'My own security group'
  vpc vpc_object

  tags(
    Name: 'my_security_group'
  )
end

aws_security_group(my_security_group)

RSpec.describe Stackstream::AwsSecurityGroup do
  it 'comes back as an object' do
    expect(MySecurityGroup).not_to be nil
  end
end
