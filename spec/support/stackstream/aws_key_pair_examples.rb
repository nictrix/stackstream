require 'stackstream/aws_key_pair'

RSpec.shared_context '#aws_key_pair' do
  let(:my_key_pair) do
    extend Stackstream::Stack

    aws_key_pair 'my_key_pair' do
      key_name 'id_rsa'
      public_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDK3+CuaX1YAc9eq5BttX' \
                          'jOdoz2klHEnPgKnbyMz2+VdCzCJaYWlkDMiyrTpgSPtNIH0s' \
                          'd3p585QLBR5Xj/ye1ySOOiVW8JSYWanho9CK457IL56jQVbU' \
                          '3JTVSNvOZmUv7nZfMyXmU5JuYyMSId2WCM4xYhBhWIPzBSrK' \
                          'yor93mZRK9pNanN9Dlss61drEkCT3Z4JRUuT53ERX3vOrVYe' \
                          '1ygoy3lu92RhgG4+5rB4bbnnHWrEj7snCYmFPJKWjtoLl1bQ' \
                          'w8Ww7uePukj8aPcFcB+MSx5axyfQEyWxFPn+N5LzuwWXzKO0'\
                          'lJ+YPpYinG+soWdsrnmCbLeF4PXEkrLGwf'
    end

    my_key_pair
  end
end
