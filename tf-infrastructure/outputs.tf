output "aws_service_discovery_private_dns_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.private.id
}

output "aws_service_discovery_private_dns_namespace_name" {
  value = aws_service_discovery_private_dns_namespace.private.name
}

output "service_discovery_private_dns_namespace_hosted_zone" {
  value = aws_service_discovery_private_dns_namespace.private.hosted_zone
}

output "service_discovery_service_arn" {
  value = aws_service_discovery_service.this.arn
}