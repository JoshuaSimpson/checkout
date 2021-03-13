variable "region" {
  default = "eu-west-1"
  type = string
  description = "The AWS region that you want to host your application in"
}

variable "domain" {
  default = "checkout.josh-simpson.me"
  type = "string"
  description = "The domain name for a domain you have in Route53"
}

variable "api-subdomain" {
  default = "api"
  type = "string"
  description = "The subdomain you want to host your API at"
}

variable "cluster_name" {
  default = "checkout-app"
  type = string
  description = "The name you want for the cluster that your service will live in"
}

variable "service_name" {
  default = "api"
  type = string
  description = "The name of your backend service"
}