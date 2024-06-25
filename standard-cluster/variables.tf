variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "platform"
}

variable "instance_type" {
  type    = string
  default = "m5.large"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}