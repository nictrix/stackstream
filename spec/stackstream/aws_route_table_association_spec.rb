require 'support/stackstream/aws_route_table_association_examples'

RSpec.describe Stackstream::AwsRouteTableAssociation do
  include_context '#aws_route_table_association'

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
    it 'should be the AwsRouteTableAssociation class' do
      expect(my_route_table_association).to be_a(
        Stackstream::AwsRouteTableAssociation
      )
    end

    it 'should have subnet' do
      expect(my_route_table_association.subnet).to match(/subnet-.*/)
    end

    it 'should have route_table' do
      expect(my_route_table_association.route_table).to match(/rtb-.*/)
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_route_table_association).to receive(:state).and_return(
        'aws_route_table_association' => {
          'my_route_table_association' => {
            'provider_id' => 'rtb-mock'
          }
        }
      )
      expect(my_route_table_association.provider_id).to_not eq(
        my_route_table_association.transform.provider_id
      )
    end
  end
end
