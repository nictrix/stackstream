require 'support/stackstream/aws_route_table_examples'

RSpec.describe Stackstream::AwsRouteTable do
  include_context '#aws_route_table'

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
    it 'should be the AwsRouteTable class' do
      expect(my_route_table).to be_a(Stackstream::AwsRouteTable)
    end

    it 'should have tags' do
      expect(my_route_table.tags).to eq(
        'Name' => 'my_route_table', 'Environment' => 'Integration'
      )
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_route_table.provider_id).to eq(
        my_route_table.transform.provider_id
      )
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_route_table).to receive(:state).and_return(
        'aws_route_table' => {
          'my_route_table' => {
            'provider_id' => 'rt-mock'
          }
        }
      )
      expect(my_route_table.provider_id).to_not eq(
        my_route_table.transform.provider_id
      )
    end
  end
end
