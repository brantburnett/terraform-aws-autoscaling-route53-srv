data "aws_route53_zone" "zone" {
    zone_id = "${var.hosted_zone_id}"
}

resource "aws_lambda_function" "update_route53" {
    function_name    = "${var.function_name}"
    filename         = "${path.module}/lambda/update_route53.zip"
    source_code_hash = "${base64sha256(file("${path.module}/lambda/update_route53.zip"))}"
    runtime          = "nodejs6.10"
    handler          = "index.handler"
    role             = "${element(concat(compact(list(var.iam_role_arn)), aws_iam_role.lambda.*.arn), 0)}"
    timeout          = 30
    tags             = "${var.tags}"

    # Only allow it to execute one function at a time to prevent concurrency issues updating Route 53
    reserved_concurrent_executions = 1

    environment {
        variables = {
            HOSTED_ZONE_ID     = "${var.hosted_zone_id}"
            DOMAIN_NAME        = "${coalesce(var.domain_name, data.aws_route53_zone.zone.name)}"
            SERVICE_NAME       = "${var.service_name}"
            SERVICE_PROTOCOL   = "${var.service_protocol}"
            SERVICE_PORT       = "${var.service_port}"
            AUTOSCALING_GROUPS = "${join(";", var.autoscaling_group_names)}"
            TOPOLOGY           = "${var.topology}"
        }
    }
}

resource "aws_lambda_permission" "update_route53_allowcloudwatch" {
    statement_id   = "AllowExecutionFromCloudWatch"
    action         = "lambda:InvokeFunction"
    function_name  = "${aws_lambda_function.update_route53.function_name}"
    principal      = "events.amazonaws.com"
    source_arn     = "${aws_cloudwatch_event_rule.asg_launchorterminate.arn}"
}

resource "aws_cloudwatch_event_rule" "asg_launchorterminate" {
    name          = "${var.function_name}-ASGMonitor"
    description   = "Monitor specific autoscaling groups for scale in and out"
    event_pattern = <<PATTERN
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance Launch Successful",
    "EC2 Instance Terminate Successful"
  ],
  "detail": {
    "AutoScalingGroupName": [
      "${join("\",\"", var.autoscaling_group_names)}"
    ]
  }
}
PATTERN

}

resource "aws_cloudwatch_event_target" "update_route53" {
    rule      = "${aws_cloudwatch_event_rule.asg_launchorterminate.name}"
    target_id = "UpdateRoute53"
    arn       = "${aws_lambda_function.update_route53.arn}"
}