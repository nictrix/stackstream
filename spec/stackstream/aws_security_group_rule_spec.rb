require 'stackstream/aws_security_group_rule'

extend Stackstream::Stack

AwsSecurityGroup = Struct.new(:provider_id)
sg_object = AwsSecurityGroup.new
sg_object.provider_id = 'test-id'

aws_security_group_rule 'my_security_group_rule' do
  type 'ingress'
  from_port 0
  to_port 0
  protocol '-1'
  cidr_blocks ['0.0.0.0/0']

  security_group sg_object
end

aws_security_group_rule(my_security_group_rule)

RSpec.describe Stackstream::AwsSecurityGroupRule do
  it 'comes back as an object' do
    expect(MySecurityGroupRule).not_to be nil
  end
end
