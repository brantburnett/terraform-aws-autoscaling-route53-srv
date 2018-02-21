locals {
    iam_count = "${length(var.iam_role_arn) > 0 ? 0 : 1}"
}

data "aws_iam_policy_document" "lambda_rights" {
    statement {
        sid = "Route53"

        actions = [
            "route53:GetHostedZone",
            "route53:ChangeResourceRecordSets"
        ]

        resources = [
            "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
        ]
    }

    statement {
        sid = "AutoscalingGroups"

        actions = [
            "autoscaling:DescribeAutoScalingGroups",
            "ec2:DescribeInstances"        
        ]

        resources = [
            "*"
        ]
    }

    statement {
        sid = "Logging"

        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"    
        ]

        resources = [
            "*"
        ]
    }
}

data "aws_iam_policy_document" "lambda_trust" {
    statement {
        sid = "1"

        actions = [
            "sts:AssumeRole"
        ]

        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "lambda" {
    count = "${local.iam_count}"
    name_prefix = "AutoscalingDnsSrvLambda"

    assume_role_policy = "${data.aws_iam_policy_document.lambda_trust.json}"
}

resource "aws_iam_role_policy" "lambda_rights" {
    count = "${local.iam_count}"

    name   = "route53_access"
    role   = "${aws_iam_role.lambda.id}"
    policy = "${data.aws_iam_policy_document.lambda_rights.json}"
}