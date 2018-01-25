# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExperts/ee-microdc-terraform-stack/blob/master/LICENSE
#

resource "aws_iam_group" "dev-s3-full-access" {
  name = "dev-s3-full-access"
}

resource "aws_iam_group_policy_attachment" "AmazonS3FullAccess" {
  group      = "${aws_iam_group.dev-s3-full-access.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

