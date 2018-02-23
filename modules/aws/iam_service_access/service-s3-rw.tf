# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "service-s3-rw" {
  name = "${terraform.workspace}.service-s3-rw"
}

# k8s
resource "aws_iam_group_policy_attachment" "service-s3-rw" {
  group      = "${aws_iam_group.service-s3-rw.name}"
  policy_arn = "${aws_iam_policy.service-s3-rw.arn}"
}

# k8s
resource "aws_iam_policy" "service-s3-rw" {
  name = "${terraform.workspace}.service-s3-rw"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "cross-account-service-s3-rw" {
  name = "cross-account-service-s3-rw"
  count = "${terraform.workspace == "prod" ? 1 : 0}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.nonprod_account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cross-account-service-s3-rw" {
  name  = "cross-account-service-s3-rw"
  role  = "${aws_iam_role.cross-account-service-s3-rw.id}"
  count = "${terraform.workspace == "prod" ? 1 : 0}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "arn:aws:s3:*"
        }
    ]
}
EOF
}
