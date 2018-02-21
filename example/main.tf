resource "aws_autoscaling_group" "example" {
    name_prefix          = "${var.function_name}"
    launch_configuration = "${aws_launch_configuration.example.name}"
    min_size             = 3
    max_size             = 3
    vpc_zone_identifier  = ["${data.aws_subnet_ids.default.ids}"]

    # Don't wait for capacity before continuing with creation,
    # otherwise the lambda function will be created afte the ASG is fully started.
    # This would result in the function not being triggered for initial startup.
    wait_for_capacity_timeout = 0
}

module "autoscaling_srv" {
    source  = "brantburnett/autoscaling-route53-srv/aws"
    version = "~> 0.1.0"

    # Switch to this line for local dev
    #source = "../"

    function_name    = "${var.function_name}"
    hosted_zone_id   = "${var.hosted_zone_id}"
    service_name     = "couchbase"
    service_protocol = "tcp"
    service_port     = 11210

    autoscaling_group_names = [
        "${aws_autoscaling_group.example.name}",
    ]
}
