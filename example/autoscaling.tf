data "aws_ami" "default" {
    most_recent = true

    filter {
        name   = "name"
      values = ["amzn-ami-*-x86_64-gp2"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name   = "owner-alias"
        values = ["amazon"]
    }
}

resource "aws_security_group" "example" {
    name_prefix = "${var.function_name}"
   description = "Autoscaling Srv Example Server"
}

resource "aws_launch_configuration" "example" {
    name_prefix     = "${var.function_name}"
    image_id        = "${data.aws_ami.default.id}"
    instance_type   = "t2.micro"
    key_name        = "${var.key_pair_name}"
    security_groups = ["${aws_security_group.example.id}"]
  
    lifecycle {
        create_before_destroy = true
    }
}
