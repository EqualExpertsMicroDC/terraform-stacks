# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE

variable "domain" { }

resource "aws_ssm_parameter" "domain" {
  name  = "Domain"
  type  = "String"
  value = "${var.domain}"
  overwrite = true
}
