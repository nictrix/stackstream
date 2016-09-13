require 'stackstream/aws_instance'

extend Stackstream::Stack

AwsKeyPair = Struct.new(:provider_id)
kp_object = AwsKeyPair.new
kp_object.provider_id = 'test-id'

AwsSecurityGroup = Struct.new(:provider_id)
sg_object = AwsSecurityGroup.new
sg_object.provider_id = 'test-id'

AwsSubnet = Struct.new(:provider_id)
sb_object = AwsSubnet.new
sb_object.provider_id = 'test-id'

aws_instance 'my_instance' do
  ami 'ami-13be557e'
  instance_type 't2.micro'
  key_name kp_object
  vpc_security_group_ids [
    sg_object
  ]
  subnet_id sb_object

  tags(
    Name: 'my_instance'
  )
end

aws_instance(my_instance)

RSpec.describe Stackstream::AwsInstance do
  it 'comes back as an object' do
    expect(MyInstance).not_to be nil
  end
end
