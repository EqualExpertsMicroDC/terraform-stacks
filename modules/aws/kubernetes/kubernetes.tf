# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#
variable "environment" { }
variable "public_zone_id" { }
variable "kubernetes_api_elb" { }

resource "aws_route53_record" "kubernetes_api_external" {
  zone_id = "${var.public_zone_id}"
  name    = "api${var.environment == prod ? "" : ".${var.environment}"}"
  type    = "A"

  alias {
    name                   = "${var.kubernetes_api_elb}"
    evaluate_target_health = true
  }
}
