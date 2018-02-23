# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_role" "cross_account_jenkins-parameter-store" {
  name = "CrossAccountJenkinsParameterStore"
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

resource "aws_iam_role_policy" "cross_account_jenkins-parameter-store" {
  name = "CrossAccountJenkinsParameterStore"
  role = "${aws_iam_role.cross_account_jenkins-parameter-store.id}"
  count = "${terraform.workspace == "prod" ? 1 : 0}"

# TODO: maybe flip the parameters around so that environment is first
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ssm:GetParameters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
