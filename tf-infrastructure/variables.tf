variable "family" {
  type    = string
  default = "hello-world-family"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "ingress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "subnet_ids" {
  type    = list(string)
  default = [""]
}

variable "ecs_service_name" {
  type    = string
  default = "hello-world"
}

variable "service_name" {
  type    = string
  default = "hello-world"
}

variable "domain_name" {
  type    = string
  default = "hello-world"
}

variable "instance_dns" {
  type    = string
  default = "hello-world"
}

variable "desired_count" {
  type    = string
  default = "1"
}

variable "cluster_cloud_watch_log_group_name" {
  type    = string
  default = "hello-world-log-group"
}