output "instance_ip_addr" {
  value = aws_instance.demoserver.private_ip
}

output "aws_availability_zones" {
  value = data.aws_availability_zones.available
}

output "vpc_id" {
  value = aws_vpc.demovpc.id
}