variable "environment" {
  default = "interview"
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "desired_instances" {
  type = number
}

variable "min_instances" {
  type = number
}

variable "max_instances" {
  type = number
}

variable "desired_containers" {
  type = number
}

variable "zone_id" {
  description = "ID for the Route53 Hosted Zone"
  type = string
}

variable "root_domain" {
  description = "Root domain for Route53 Hosted Zone"
  type = string
}

variable "subdomain" {
  description = "Subdomain you want the service to live at"
  type = string
}

variable "default_health_check_path" {
  description = "Health check path for the default target group"
  default     = "/"
}

variable "log_retention_in_days" {
  default = 28
  type = number
}

variable "region" {
  type = string
}