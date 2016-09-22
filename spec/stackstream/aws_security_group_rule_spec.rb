require 'support/stackstream/aws_security_group_rule_examples'

RSpec.describe Stackstream::AwsSecurityGroupRule do
  include_context '#aws_security_group_rule'

  before(:each) do
    Fog.mock!
    Fog::Mock.reset
    begin
      File.delete('formation.state')
    rescue
      nil
    end
  end

  context '#my_security_group_rule_ingress_cidr' do
    context '#create' do
      it 'should be the AwsSecurityGroupRule class' do
        expect(my_security_group_rule_ingress_cidr).to be_a(Stackstream::AwsSecurityGroupRule)
      end

      it 'should have type' do
        expect(my_security_group_rule_ingress_cidr.type).to eq('ingress')
      end

      it 'should have from_port' do
        expect(my_security_group_rule_ingress_cidr.from_port).to eq(1)
      end

      it 'should have to_port' do
        expect(my_security_group_rule_ingress_cidr.to_port).to eq(65535)
      end

      it 'should have protocol' do
        expect(my_security_group_rule_ingress_cidr.protocol).to eq('tcp')
      end

      it 'should have cidr_blocks' do
        expect(my_security_group_rule_ingress_cidr.cidr_blocks).to eq(['0.0.0.0/0'])
      end

      it 'should have security_group' do
        expect(my_security_group_rule_ingress_cidr.security_group).to match(/sg-.*/)
      end
    end

    context '#destroy' do
      it 'should destroy before create' do
        allow(my_security_group_rule_ingress_cidr).to receive(:state).and_return(
          'aws_security_group_rule' => {
            'my_security_group_rule_ingress_cidr' => {
              "named_object"=>"my_security_group_rule_ingress_cidr",
              'type' => 'ingress', 'from_port' => 80, 'to_port' => 80,
              'protocol' => 'udp',
              'cidr_blocks' => ['192.168.1.0/24'],
              'security_group' => my_security_group
            }
          }
        )
        # TODO: need to see why this errors out with both matching
        # expect(my_security_group_rule_ingress_cidr.cidr_blocks).to_not eq(
        #   my_security_group_rule_ingress_cidr.transform.cidr_blocks)
      end
    end
  end
end
