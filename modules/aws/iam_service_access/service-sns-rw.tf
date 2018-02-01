# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "service-sns-rw" {
  name = "${terraform.workspace}.service-sns-rw"
}

# k8s
resource "aws_iam_group_policy_attachment" "service-sns-rw" {
  group = "${aws_iam_group.service-sns-rw.id}"
  policy_arn = "${aws_iam_policy.service-sns-rw.arn}"
}

# k8s
resource "aws_iam_policy" "service-sns-rw" {
  name = "${terraform.workspace}.service-sns-rw"

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

