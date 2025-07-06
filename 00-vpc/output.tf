/* output "azs_info" {
  value = data.aws_availability_zones.available
}

output "subnet_info" {
  value = aws_subnet.public
} */

output "public_subnet-ids" {
  value = module.vpc.public_subnet_ids
}