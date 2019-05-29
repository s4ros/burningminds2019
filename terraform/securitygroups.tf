resource "aws_security_group" "burningminds" {
  name        = "${var.project}-${var.environment}-all-in-one"
  description = "Loadbalancer security group"
  # vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Project_name = "${var.project}"
    Name         = "${var.project}-${var.environment}"
    Terraform    = true
    Environment  = "${var.environment}"
  }
}
