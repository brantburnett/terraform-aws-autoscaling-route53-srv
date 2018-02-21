provider "aws" {
    # Assumes that the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables are set for authentication  # May also optionally use the AWS_SESSION_TOKEN environment variable

    region = "${var.region}"

    version = "~> 1.9"
}
