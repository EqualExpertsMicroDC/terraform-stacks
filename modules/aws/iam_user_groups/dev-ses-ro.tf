# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "dev-ses-ro" {
  name = "dev-ses-ro"
}

resource "aws_iam_group_policy_attachment" "SESReadOnlyAccess-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESReadOnlyAccess"
}
