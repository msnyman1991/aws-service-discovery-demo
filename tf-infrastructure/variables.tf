variable "family" {
  type = string
}

variable "container_definition" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type = string
}

variable "ingress_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "subnet_ids" {
  type = list(string)
}

variable "ecs_service_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ttl" {
  type = string
}

variable "type" {
  type = string
}

variable "routing_policy" {
  type = string
}

variable "instance_dns" {
  type = string
}

variable "desired_count" {
  type    = string
  default = "1"
}

variable "cluster_cloud_watch_log_group_name" {
  type = string
}