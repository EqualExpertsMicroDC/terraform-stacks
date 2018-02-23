# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "service-ses-send" {
  name = "${terraform.workspace}.service-ses-send"
}

# k8s
resource "aws_iam_group_policy_attachment" "service-ses-send" {
  group = "${aws_iam_group.service-ses-send.id}"
  policy_arn = "${aws_iam_policy.service-ses-send.arn}"
}

# k8s
resource "aws_iam_policy" "service-ses-send" {
  name = "${terraform.workspace}.service-ses-send"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

