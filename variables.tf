variable "function_name" {
    type = "string"
    description = "Unique function name for the Lambda function."
}

variable "hosted_zone_id" {
    type = "string"
    description = "Hosted zone ID of the DNS SRV record."
}

variable "domain_name" {
    description = "Domain name of the service.  Defaults to the domain name of the hosted zone."
    default = ""
}

variable "topology" {
    description = "'private' to use private DNS names of the instances, 'public' to use public DNS names.  Defaults to 'private'."
    default = "private"
}

variable "autoscaling_group_names" {
    type = "list"
    description = "Names of the autoscaling groups to monitor and register in the DNS SRV record."
}

variable "service_name" {
    type = "string"
    description = "Name of the service used to build the DNS entry.  Do not include the leading underscore."
}

variable "service_protocol" {
    description = "Name of the protocol used to build the DNS entry (i.e. 'tcp').  Do not include the leading underscore."
    default = "tcp"
}

variable "service_port" {
    type = "string"
    description = "Port number of the service."
}

variable "iam_role_arn" {
    description = "Optional IAM role for the Lambda function, one will be created if blank."
    default = ""
}

variable "tags" {
    description = "Optional tags to apply to the Lambda function."
    default = {}
}