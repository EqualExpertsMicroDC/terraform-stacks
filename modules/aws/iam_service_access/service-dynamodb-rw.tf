# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "service-dynamodb-rw" {
  name = "${terraform.workspace}.service-dynamodb-rw"
}

# k8s
resource "aws_iam_group_policy_attachment" "service-dynamodb-rw" {
  group      = "${aws_iam_group.service-dynamodb-rw.name}"
  policy_arn = "${aws_iam_policy.service-dynamodb-rw.arn}"
}

# k8s
resource "aws_iam_policy" "service-dynamodb-rw" {
  name = "${terraform.workspace}.service-dynamodb-rw"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchWriteItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "cross-account-service-dynamodb-rw" {
  name = "cross-account-service-dynamodb-rw"
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

resource "aws_iam_role_policy" "cross-account-service-dynamodb-rw" {
  name  = "cross-account-service-dynamodb-rw"
  role  = "${aws_iam_role.cross-account-service-dynamodb-rw.id}"
  count = "${terraform.workspace == "prod" ? 1 : 0}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:*"
        }
    ]
}
EOF
}
