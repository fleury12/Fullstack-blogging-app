output "cluster_id" {
  value = aws_eks_cluster.fleury.id
}

output "node_group_id" {
  value = aws_eks_node_group.fleury.id
}

output "vpc_id" {
  value = aws_vpc.fleury_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.fleury_public_subnet[*].id
}

output "instance_ids" {
  value = { for name, instance in aws_instance.fleet : name => instance.id }
}

output "instance_public_ips" {
  value = { for name, instance in aws_instance.fleet : name => instance.public_ip }
}

output "instance_private_ips" {
  value = { for name, instance in aws_instance.fleet : name => instance.private_ip }
}
