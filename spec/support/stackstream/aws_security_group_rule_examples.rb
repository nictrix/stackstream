require 'support/stackstream/aws_security_group_examples'
require 'stackstream/aws_security_group_rule'

RSpec.shared_context '#aws_security_group_rule' do
  include_context '#aws_security_group'

  let(:my_security_group_rule_ingress_cidr) do
    extend Stackstream::Stack

    aws_security_group_rule 'my_security_group_rule_ingress_cidr' do
      type 'ingress'
      from_port 1
      to_port 65_535
      protocol 'tcp'
      cidr_blocks ['0.0.0.0/0']

      security_group my_security_group
    end

    my_security_group_rule_ingress_cidr
  end

  # let(:my_security_group_rule_egress_cidr) do
  #   extend Stackstream::Stack

  #   aws_security_group_rule 'my_security_group_rule_egress_cidr' do
  #     type 'egress'
  #     from_port 1
  #     to_port 65535
  #     protocol 'tcp'
  #     cidr_blocks ['0.0.0.0/0']

  #     security_group my_security_group
  #   end

  #   my_security_group_rule_egress_cidr
  # end

  # let(:my_security_group_rule_ingress_sg) do
  #   extend Stackstream::Stack

  #   aws_security_group_rule 'my_security_group_rule_ingress_sg' do
  #     type 'ingress'
  #     from_port 1
  #     to_port 65535
  #     protocol 'tcp'

  #     security_group my_security_group
  #     source_security_groups my_security_group
  #   end

  #   my_security_group_rule_ingress_sg
  # end

  # let(:my_security_group_rule_egress_sg) do
  #   extend Stackstream::Stack

  #   aws_security_group_rule 'my_security_group_rule_egress_sg' do
  #     type 'egress'
  #     from_port 1
  #     to_port 65535
  #     protocol 'tcp'

  #     security_group my_security_group
  #     source_security_groups my_security_group
  #   end

  #   my_security_group_rule_egress_sg
  # end
end
