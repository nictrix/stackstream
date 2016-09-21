require 'support/stackstream/aws_vpc_examples'
require 'stackstream/aws_security_group'

RSpec.shared_context '#aws_security_group' do
  include_context '#aws_vpc'

  let(:my_security_group) do
    extend Stackstream::Stack

    aws_security_group 'my_security_group' do
      name 'self-security-group'
      description 'my security group'
      vpc my_vpc

      tags(
        Environment: 'Integration'
      )
    end

    my_security_group
  end
end
