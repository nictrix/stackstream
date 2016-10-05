require 'support/stackstream/aws_instance_examples'

RSpec.describe Stackstream::AwsInstance do
  include_context '#aws_instance'

  before(:each) do
    Fog.mock!
    Fog::Mock.reset

    allow_any_instance_of(Stackstream::AwsInstance).to \
      receive(:image_attributes).and_return(
        'blockDeviceMapping' => [
          { 'deviceName' => '/dev/xvda', 'snapshotId' => 'snap-xxxxxxxx',
            'volumeSize' => 8, 'deleteOnTermination' => 'true',
            'volumeType' => 'standard' }
        ], 'rootDeviceName' => '/dev/xvda'
      )
    begin
      File.delete('formation.state')
    rescue
      nil
    end
  end

  context '#create' do
    it 'should be the AwsInstance class' do
      expect(my_instance).to be_a(Stackstream::AwsInstance)
    end

    it 'should have an ami' do
      expect(my_instance.ami).to eq('ami-13be557e')
    end

    it 'should have a key_name' do
      expect(my_instance.key_name).to eq('id_rsa')
    end

    it 'should have vpc_security_groups' do
      expect(my_instance.vpc_security_groups.to_s).to match(/.*sg-*/)
    end

    it 'should have a subnet' do
      expect(my_instance.subnet).to match(/subnet-*/)
    end

    it 'should have an instance_type' do
      expect(my_instance.instance_type).to eq('m3.xlarge')
    end

    it 'should have a root_block_device volume_size' do
      expect(my_instance.root_block_device['volume_size']).to eq(10)
    end

    it 'should have delete_on_termination volume_size' do
      expect(my_instance.root_block_device['delete_on_termination']).to \
        eq(false)
    end

    it 'should have volume_type' do
      expect(my_instance.root_block_device['volume_type']).to eq('io1')
    end

    it 'should have iops' do
      expect(my_instance.root_block_device['iops']).to eq(1000)
    end

    it 'should have tags' do
      expect(my_instance.tags).to eq(
        'Name' => 'my_instance', 'Environment' => 'Integration'
      )
    end
  end

  context '#modify' do
    it 'should be idempotent' do
      expect(my_instance.provider_id).to eq(my_instance.transform.provider_id)
    end
  end

  context '#destroy' do
    it 'should destroy before create' do
      allow(my_instance).to receive(:state).and_return(
        'aws_instance' => {
          'my_instance' => {
            'ami' => 'ami-75k30z1cs',
            'subnet' => 'subnet-3s4rss', 'provider_id' => 'instance-mock'
          }
        }
      )
      expect(my_instance.provider_id).to_not \
        eq(my_instance.transform.provider_id)
    end
  end
end
