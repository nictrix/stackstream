aws_vpc 'vpc_boot_instances_example' do
  cidr_block '192.168.0.0/16'
  enable_dns_hostnames true
  enable_dns_support true
  tags(
    Environment: 'Example'
  )
end

#
# aws_subnet 'subnet_1c' do
#   vpc vpc_boot_instances_example
#
#   cidr_block '192.168.1.0/24'
#   availability_zone 'us-east-1c'
#   map_public_ip_on_launch true
#
#   tags(
#     Environment 'Example'
#   )
# end
#
# aws_internet_gateway 'internet_gateway' do
#   vpc vpc_boot_instances_example
#
#   tags(
#     Environment 'Example'
#   )
# end
#
# aws_route_table 'subnet_route_table' do
#   vpc vpc_boot_instances_example
#
#   tags(
#     Environment 'Example'
#   )
# end
#
# aws_route "subnet_route_default_outbound" do
#     route_table subnet_route_table
#     destination_cidr_block '0.0.0.0/0'
#     gateway internet_gateway
# end
#
# aws_route_table_association 'us_east_1c_subnet' do
#   subnet subnet_1c
#   route_table subnet_route_table
# end
#
# aws_security_group 'vpc_sg_for_instances' do
#   name 'vpc_sg_for_instances'
#   description 'For my instances'
#   vpc vpc_boot_instances_example
#
#   tags(
#     Environment 'Example'
#   )
# end
#
#
# aws_security_group_rule 'ingress' do
#   type 'ingress'
#   from_port 443
#   to_port 443
#   protocol 'tcp'
#   cidr_blocks ['0.0.0.0/0']
# end
#
# aws_security_group_rule 'egress' do
#   type 'egress'
#   from_port 0
#   to_port 0
#   protocol '-1'
#   cidr_blocks ['0.0.0.0/0']
# end
#
# aws_key_pair 'my_ssh_key_pair' do
#   key_name 'my_ssh_key_pair'
#   public_key 'insecure.pub'
# end
#
# aws_instance 'vpc_instance_1' do
#   ami 'ami-*
#   instance_type 't2.micro'
#   key_name my_ssh_key_pair
#   vpc_security_groups [
#     vpc_sg_for_instances
#   ]
#   subnet subnet_1c
#
#   tags(
#     Environment 'Example'
#   )
# end
#
# aws_instance 'vpc_instance_2' do
#   ami 'ami-*'
#   associate_public_ip_address true
#   instance_type 't2.micro'
#   key_name my_ssh_key_pair
#   vpc_security_groups [
#     vpc_sg_for_instances
#   ]
#   subnet subnet_1c
#
#   tags(
#     Environment 'Example'
#   )
# end
