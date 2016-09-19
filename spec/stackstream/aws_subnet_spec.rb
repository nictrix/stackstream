require 'support/stackstream/aws_subnet_examples'

RSpec.describe Stackstream::AwsSubnet do
  include_context '#aws_subnet'

  before(:each) do
    Fog.mock!
    Fog::Mock.reset
    File.delete('formation.state') rescue nil
  end

  context '#create' do
    it 'should be the AwsSubnet class' do
      expect(my_subnet).to be_a(Stackstream::AwsSubnet)
    end

    it 'should have cidr_block' do
      expect(my_subnet.cidr_block).to eq('192.168.1.0/24')
    end

    it 'should have availability_zone' do
      expect(my_subnet.availability_zone).to eq('us-east-1c')
    end

    it 'should have map_public_ip_on_launch' do
      expect(my_subnet.map_public_ip_on_launch).to eq(true)
    end

    it 'should have vpc' do
      expect(my_subnet.vpc).to match(/vpc-*/)
    end

    it 'should have tags' do
      expect(my_subnet.tags).to eq(
        'Name' => 'my_subnet', 'Environment' => 'Integration'
      )
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_subnet.provider_id).to eq(my_subnet.transform.provider_id)
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_subnet).to receive(:state).and_return(
      {'aws_subnet' => { 'my_subnet' => { 'cidr_block' => '10.10.1.0/24',
        'availability_zone' => 'us-east-1a', 'provider_id' => 'subnet-mock'}}})
      expect(my_subnet.provider_id).to_not eq(my_subnet.transform.provider_id)
    end
  end
end
