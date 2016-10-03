require 'support/stackstream/aws_ami_from_instance_examples'

RSpec.describe Stackstream::AwsAmiFromInstance do
  include_context '#aws_ami_from_instance'

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
    it 'should be the AwsAmiFromInstance class' do
      expect(my_ami_from_instance).to be_a(Stackstream::AwsAmiFromInstance)
    end

    it 'should have a source_instance_id' do
      expect(my_ami_from_instance.source_instance_id).to eq('i-xxxxxxx')
    end

    it 'should have a name' do
      expect(my_ami_from_instance.name).to eq('this is my ami')
    end

    it 'should have a description' do
      expect(my_ami_from_instance.description).to eq(
        'this is my ami from an instance'
      )
    end

    it 'should have snapshot_without_reboot' do
      expect(my_ami_from_instance.snapshot_without_reboot).to eq(false)
    end

    it 'should recieve an id' do
      expect(my_ami_from_instance.provider_id).to match(/ami-*/)
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_ami_from_instance.provider_id).to eq(
        my_ami_from_instance.transform.provider_id
      )
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_ami_from_instance).to receive(:state).and_return(
        'aws_ami_from_instance' => {
          'my_ami_from_instance' => {
            'name' => 'this is my 2nd generation',
            'source_instance_id' => 'i-xNxNxNx',
            'snapshot_without_reboot' => true, 'provider_id' => 'ami-mock'
          }
        }
      )
      expect(my_ami_from_instance.provider_id).to_not eq(
        my_ami_from_instance.transform.provider_id
      )
    end
  end
end
