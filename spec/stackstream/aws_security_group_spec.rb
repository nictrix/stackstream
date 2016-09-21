require 'support/stackstream/aws_security_group_examples'

RSpec.describe Stackstream::AwsSecurityGroup do
  include_context '#aws_security_group'

  before(:each) do
    Fog.mock!
    Fog::Mock.reset
    begin
      File.delete('formation.state')
    rescue
      nil
    end
  end

  context '#create' do
    it 'should be the AwsSecurityGroup class' do
      expect(my_security_group).to be_a(Stackstream::AwsSecurityGroup)
    end

    it 'should have name' do
      expect(my_security_group.name).to eq('self-security-group')
    end

    it 'should have description' do
      expect(my_security_group.description).to eq('my security group')
    end

    it 'should have vpc' do
      expect(my_security_group.vpc).to match(/vpc-.*/)
    end

    it 'should have tags' do
      expect(my_security_group.tags).to eq(
        'Name' => 'my_security_group', 'Environment' => 'Integration'
      )
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_security_group.provider_id).to eq(
        my_security_group.transform.provider_id
      )
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_security_group).to receive(:state).and_return(
        'aws_security_group' => {
          'my_security_group' => {
            'name' => 'my_security_group_new',
            'description' => 'My new security group', 'provider_id' => 'sg-mock'
          }
        }
      )
      expect(my_security_group.provider_id).to_not eq(
        my_security_group.transform.provider_id
      )
    end
  end
end
