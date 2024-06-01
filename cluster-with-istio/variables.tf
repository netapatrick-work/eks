variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "istio"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}