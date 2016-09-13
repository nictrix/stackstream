require 'stackstream/aws_key_pair'

extend Stackstream::Stack

aws_key_pair 'my_key_pair' do
  key_name 'id_rsa'
  public_key '~/.ssh/id_rsa'
end

aws_key_pair(my_key_pair)

RSpec.describe Stackstream::AwsKeyPair do
  it 'comes back as an object' do
    expect(MyKeyPair).not_to be nil
  end
end
