# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

variable account { }
variable prod_account_id { }
variable nonprod_account_id { }

resource "aws_iam_group" "cross-account-admins" {
  name  = "cross-account-admins"
  count = "${var.account == "prod" ? 1 : 0}"
}

resource "aws_iam_policy_attachment" "cross-account-admins-prod" {
  name       = "cross-account-admins-policy-attach"
  count      = "${var.account == "prod" ? 1 : 0}"
  groups     = ["${aws_iam_group.cross-account-admins.name}"]
  policy_arn = "${aws_iam_policy.prod_account_administrator_access.arn}"
}

resource "aws_iam_policy_attachment" "cross-account-admins-nonprod" {
  name       = "cross-account-admins-policy-attach"
  count      = "${var.account == "prod" ? 1 : 0}"
  groups     = ["${aws_iam_group.cross-account-admins.name}"]
  policy_arn = "${aws_iam_policy.nonprod_account_administrator_access.arn}"
}

resource "aws_iam_policy" "nonprod_account_administrator_access" {
  name = "NonprodAccountAdministratorAccess"
  count = "${var.account == "prod" ? 1 : 0}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.nonprod_account_id}:role/CrossAccountAdministratorAccess"
    }
}
EOF
}

resource "aws_iam_policy" "prod_account_administrator_access" {
  name = "ProdAccountAdministratorAccess"
  count = "${var.account == "prod" ? 1 : 0}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.prod_account_id}:role/CrossAccountAdministratorAccess"
    }
}
EOF
}

resource "aws_iam_role" "cross_account_administrator_access" {
  name = "CrossAccountAdministratorAccess"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.prod_account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  role       = "${aws_iam_role.cross_account_administrator_access.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
