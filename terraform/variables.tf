variable "aws_region" {
  default = "eu-central-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "project" {
  default = "burningminds"
}

variable "environment" {
  default = "2019"
}

variable "r53_zone" {
  default = ""
}

variable "r53_domain" {
  default = "bm.devguru.co"
}
