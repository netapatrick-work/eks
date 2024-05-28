data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter{
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:az"
    values = ["abc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "tag:az"
    values = ["def"]
  }
}
