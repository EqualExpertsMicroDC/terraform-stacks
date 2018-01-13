# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_policy_attachment" "IAMSelfManageServiceSpecificCredentials-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMSelfManageServiceSpecificCredentials"
}

resource "aws_iam_group_policy_attachment" "IAMUserSSHKeys-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserSSHKeys"
}

resource "aws_iam_group_policy_attachment" "IAMUserChangePassword-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_group_policy_attachment" "AmazonDynamoDBReadOnlyAccess-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "AmazonSNSReadOnlyAccess-dev" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess"
}

resource "aws_iam_group_policy" "developers-self-manage-iam-creds" {
  name  = "developers-self-manage-iam-creds"
  group      = "${aws_iam_group.developers.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "iam:ListUsers",
                "iam:GetAccountPasswordPolicy",
                "iam:GetAccountSummary",
                "iam:ListAccount*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:*AccessKey*",
                "iam:ChangePassword",
                "iam:GetUser",
                "iam:ListAccountAliases",
                "iam:ListAttachedUserPolicies",
                "iam:ListUserPolicies",
                "iam:*LoginProfile",
                "iam:*ServiceSpecificCredential*",
                "iam:*SSHPublicKey*",
                "iam:*SigningCertificate*"
            ],
            "Resource": [ "arn:aws:iam::*:user/$${aws:username}" ]
        }
    ]
}
EOF
}

resource "aws_iam_group_policy" "developers-self-manage-MFA" {
  name  = "developers-self-manage-MFA"
  group      = "${aws_iam_group.developers.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Sid": "AllowUsersToCreateEnableResyncDeleteTheirOwnVirtualMFADevice",
            "Effect": "Allow",
            "Action": [
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:DeactivateMFADevice",
                "iam:DeleteVirtualMFADevice"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/$${aws:username}",
                "arn:aws:iam::*:user/$${aws:username}"
            ]
        },
        {
            "Sid": "AllowUsersToDeactivateTheirOwnVirtualMFADevice",
            "Effect": "Allow",
            "Action": [
                "iam:ListVirtualMFADevices",
                "iam:ListMFADevices"
            ],
            "Resource": [
                "arn:aws:iam::*:mfa/$${aws:username}",
                "arn:aws:iam::*:user/$${aws:username}"
            ],
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": true
                }
            }
        },
        {
            "Sid": "AllowUsersToListMFADevicesandUsersForConsole",
            "Effect": "Allow",
            "Action": [
                "iam:ListMFADevices",
                "iam:ListVirtualMFADevices",
                "iam:ListUsers"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
