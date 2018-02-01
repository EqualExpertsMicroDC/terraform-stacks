# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#
resource "aws_iam_role" "cross-account-service-dynamodb-full" {
  name = "cross-account-service-dynamodb-full"
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

resource "aws_iam_role_policy" "cross-account-service-dynamodb-full" {
  name  = "cross-account-service-dynamodb-full"
  role  = "${aws_iam_role.cross-account-service-dynamodb-full.id}"
  count = "${terraform.workspace == "prod" ? 1 : 0}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*"
            ],
            "Resource": "arn:aws:dynamodb:*"
        }
    ]
}
EOF
}
