# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

resource "aws_iam_group" "vpn-access" {
  name = "vpn-access"
}
