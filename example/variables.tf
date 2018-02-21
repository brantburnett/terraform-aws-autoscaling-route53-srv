variable "region" {
    description = "AWS region for the example"
    default     = "us-east-1"
}

variable "function_name" {
    description = "Unique function name for the Lambda function"
    default     = "autoscaling-srv-example"
}

variable "hosted_zone_id" {
    type        = "string"
    description = "Hosted zone ID of the DNS SRV record"
}

variable "key_pair_name" {
    type        = "string"
    description = "EC2 key pair for launched example instances"
}
