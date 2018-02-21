# AWS Autoscaling Route 53 DNS SRV

## Overview

This module creates the necessary AWS objects to manage a Route 53 DNS SRV record for one or more autoscaling groups.
Primarily, it creates a Lambda function which is triggered anytime one of the autoscaling groups scales in or out,
which then updates the DNS SRV record.

## Usage

Simply supply a hosted zone, a list of auto scaling groups, and information about the service you want to register.

For example, to track nodes in a Couchbase cluster:

```terraform
module "autoscaling_srv" {
    source  = "brantburnett/autoscaling-route53-srv/aws"
    version = "~> 0.1.0"

    function_name    = "CouchbaseClusterSrvManager"
    hosted_zone_id   = "Z0982089720"
    service_name     = "couchbase"
    service_protocol = "tcp"
    service_port     = 11210

    autoscaling_group_names = [
        "${aws_autoscaling_group.example.name}",
    ]
}
```

## Adding to an existing Autoscaling Group

If you apply this module to an existing autoscaling group, you must manually trigger the Lambda function
the first time to create the Route 53 record.  Normally, it is only triggered when instances are launched
or terminated in the auto scaling group.

## Adding to a new Autoscaling Group

If you are adding to a new autoscaling group, be sure to set "wait_for_capacity_timeout" to "0" on the
autoscaling group.  Otherwise Terraform will wait for the instances to be available before moving on
to create the Lambda function (which will usually depend the name of the ASG).  This will cause the
Lambda function to not be triggered initially, and the Route 53 record will not be created.

Note: If this happens accidentally, you may trigger the Lambda function from the AWS Console to
create the Route 53 record.

## Example

There is an example implementation which creates an autoscaling group and registers it in the
[example folder](https://github.com/brantburnett/terraform-aws-autoscaling-route53-srv/tree/master/example).