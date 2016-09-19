require 'support/stackstream/aws_vpc_examples'

RSpec.describe Stackstream::AwsVpc do
  include_context '#aws_vpc'

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
    it 'should be the AwsVpc class' do
      expect(my_vpc).to be_a(Stackstream::AwsVpc)
    end

    it 'should have cidr_block' do
      expect(my_vpc.cidr_block).to eq('192.168.0.0/16')
    end

    it 'should have instance_tenancy' do
      expect(my_vpc.instance_tenancy).to eq('default')
    end

    it 'should have enable_dns_support' do
      expect(my_vpc.enable_dns_support).to eq(true)
    end

    it 'should have enable_dns_hostnames' do
      expect(my_vpc.enable_dns_hostnames).to eq(true)
    end

    it 'should have tags' do
      expect(my_vpc.tags).to eq(
        'Name' => 'my_vpc', 'Environment' => 'Integration'
      )
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_vpc.provider_id).to eq(my_vpc.transform.provider_id)
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_vpc).to receive(:state).and_return(
        'aws_vpc' => {
          'my_vpc' => {
            'cidr_block' => '10.10.0.0/16',
            'instance_tenancy' => 'default', 'provider_id' => 'vpc-mock'
          }
        }
      )
      expect(my_vpc.provider_id).to_not eq(my_vpc.transform.provider_id)
    end
  end
end
