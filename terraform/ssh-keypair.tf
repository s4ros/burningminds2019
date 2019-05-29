resource "aws_key_pair" "deploy" {
  key_name   = "stefan-ssh-key"
  public_key = "${file("${path.module}/stefan.burningminds2019.pub")}"
}
