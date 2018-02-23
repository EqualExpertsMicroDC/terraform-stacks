# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#
variable "account" { }
variable "project" { }
variable "multi_region_trail" { default = false }

resource "aws_cloudtrail" "microdc_cloudtrail" {
  name                          = "${var.project}-${var.account}-microdc-cloudtrail"
  s3_bucket_name                = "${aws_s3_bucket.microdc_cloudtrail.id}"
  include_global_service_events = true
  is_multi_region_trail         = "${var.multi_region_trail}"
}

resource "aws_s3_bucket" "microdc_cloudtrail" {
  bucket        = "${var.project}-${var.account}-microdc-cloudtrail"
  force_destroy = true

  lifecycle_rule {
    prefix = "/"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.project}-${var.account}-microdc-cloudtrail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.project}-${var.account}-microdc-cloudtrail/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

output "cloudtrail_s3_bucket" { value = "${aws_s3_bucket.microdc_cloudtrail.id}" }
