# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "dev-ses-full-access" {
  name = "dev-ses-full-access"
}

resource "aws_iam_group_policy_attachment" "SESFullAccess-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}
