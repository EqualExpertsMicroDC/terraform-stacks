# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "dev-sns-rw" {
  name = "dev-sns-rw"
}

resource "aws_iam_group_policy" "dev-sns-rw" {
  name  = "dev-sns-rw_policy"
  group = "${aws_iam_group.dev-sns-rw.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

