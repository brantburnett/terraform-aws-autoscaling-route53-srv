output "update_route53_lambda_arn" {
    description = "ARN of the lambda function which is updating the Route 53 records"
    value = "${aws_lambda_function.update_route53.arn}"
}