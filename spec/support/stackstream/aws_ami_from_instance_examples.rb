require 'stackstream/aws_ami_from_instance'

RSpec.shared_context '#aws_ami_from_instance' do
  let(:my_ami_from_instance) do
    extend Stackstream::Stack

    aws_ami_from_instance 'my_ami_from_instance' do
      name 'this is my ami'
      description 'this is my ami from an instance'
      snapshot_without_reboot false
      source_instance_id 'i-xxxxxxx'
    end

    my_ami_from_instance
  end
end
