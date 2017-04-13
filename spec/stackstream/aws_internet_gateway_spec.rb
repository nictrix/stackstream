require 'support/stackstream/aws_internet_gateway_examples'

RSpec.describe Stackstream::AwsInternetGateway do
  include_context '#aws_internet_gateway'

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
    it 'should be the AwsInternetGateway class' do
      expect(my_internet_gateway).to be_a(Stackstream::AwsInternetGateway)
    end

    it 'should have tags' do
      expect(my_internet_gateway.tags).to eq(
        'Name' => 'my_internet_gateway', 'Environment' => 'Integration'
      )
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_internet_gateway.provider_id).to eq(
        my_internet_gateway.transform.provider_id
      )
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_internet_gateway).to receive(:state).and_return(
        'aws_internet_gateway' => {
          'my_internet_gateway' => {
            'provider_id' => 'igw-mock', 'vpc' => 'vpc-mock'
          }
        }
      )
      expect(my_internet_gateway.provider_id).to_not eq(
        my_internet_gateway.transform.provider_id
      )
    end
  end
end
