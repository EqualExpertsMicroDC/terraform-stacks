# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

variable "account"        { }
variable "tool"           { default = "terraform" }
variable "project"        { }
variable "stack"          { }
variable "prod_acount_id" { }

resource "aws_s3_bucket" "state_bucket" {
  bucket = "${var.project}-${var.tool}-${var.stack}"
  count  = "${var.account == "prod" ? 0 : 1}"
  acl    = "private"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"Allow Prod Access to ${var.project}-${var.tool}-${var.stack}",
      "Effect":"Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${var.prod_acount_id}:root"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.project}-${var.tool}-${var.stack}"
    },
    {
      "Sid":"Allow Prod Access to ${var.project}-${var.tool}-${var.stack}/*",
      "Effect":"Allow",
      "Principal": {
          "AWS": "arn:aws:iam::${var.prod_acount_id}:root"
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::${var.project}-${var.tool}-${var.stack}/*"
    }
  ]
}
EOF

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix = "/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

  tags {
    Name    = "${var.project}-${var.tool}-${var.stack}"
    Project = "${var.project}"
  }
}


output "aws-s3-bucket-state-bucket-id" { value = "${aws_s3_bucket.state_bucket.id}" }
