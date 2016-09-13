require 'stackstream/aws_vpc'

RSpec.shared_context '#aws_vpc' do
  let(:my_vpc) do
    extend Stackstream::Stack
    aws_vpc 'my_vpc' do
      cidr_block '192.168.0.0/16'
      enable_dns_hostnames true
      tags(
        Name: 'my_vpc'
      )
    end

    my_vpc
  end
end

RSpec.describe Stackstream::AwsVpc do
  include_context '#aws_vpc'

  context '#initialized' do
    it 'should be the AwsVpc class' do
      expect(my_vpc).to be_a(Stackstream::AwsVpc)
    end

    it 'should have cidr_block' do
      expect(my_vpc.cidr_block).to eq('192.168.0.0/16')
    end

    it 'should have enable_dns_hostnames' do
      expect(my_vpc.enable_dns_hostnames).to eq(true)
    end

    it 'should have tags' do
      expect(my_vpc.tags).to eq(Name: 'my_vpc')
    end
  end

  context '#create_or_modify' do
    it 'should output the provider id' do
      expect(my_vpc.create_or_modify).to eq('vpc-3235sd2')
    end
  end
end
