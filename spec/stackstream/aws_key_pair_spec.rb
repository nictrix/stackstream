require 'support/stackstream/aws_key_pair_examples'

RSpec.describe Stackstream::AwsKeyPair do
  include_context '#aws_key_pair'

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
    it 'should be the AwsKeyPair class' do
      expect(my_key_pair).to be_a(Stackstream::AwsKeyPair)
    end

    it 'should have key_name' do
      expect(my_key_pair.key_name).to eq('id_rsa')
    end

    it 'should have public_key' do
      expect(my_key_pair.public_key).to match(/ssh-rsa .*/)
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_key_pair).to receive(:state).and_return(
        'aws_key_pair' => {
          'my_key_pair' => {
            'key_name' => 'id_dsa',
            'public_key' => 'ssh-dsa'
          }
        }
      )
      expect(my_key_pair.transform.key_name).to_not eq('id_dsa')
    end
  end
end
