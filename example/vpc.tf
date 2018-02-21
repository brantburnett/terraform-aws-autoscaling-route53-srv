# Get the default VPC from Amazon
resource "aws_default_vpc" "default" {
    # Get the default VPC from Amazon
}

# Get all subnets in the VPC
data "aws_subnet_ids" "default" {
    vpc_id = "${aws_default_vpc.default.id}"
}
