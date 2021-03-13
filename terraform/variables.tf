variable "region" {
  default = "eu-west-1"
  type = string
}

variable "domain" {
  default = "checkout.josh-simpson.me"
  type = "string"
}

variable "api-subdomain" {
  default = "api"
  type = "string"
}

variable "cluster_name" {
  default = "checkout-app"
  type = string
}

variable "service_name" {
  default = "api"
  type = string
}