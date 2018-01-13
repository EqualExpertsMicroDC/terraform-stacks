# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#

variable "domain"  { }
variable "zone_id" { }


resource "aws_ses_domain_identity" "ses_domain" {
  provider = "aws.west"
  domain   = "${var.domain}"
}

resource "aws_route53_record" "ses_amazonses_verification_record" {
  zone_id = "${aws_route53_zone.zone.zone_id}"
  name    = "_amazonses"
  type    = "TXT"
  ttl     = "600"
  records = [ "${aws_ses_domain_identity.ses_domain.verification_token}" ]
}

#TODO: Required to add DKIM signing for ses emails.
# Comented out until the PR below has made it into the current release of terraform
# 2017-10-24 https://github.com/terraform-providers/terraform-provider-aws/pull/1786
#resource "aws_ses_domain_dkim" "ses_domain" {
#  domain = "${aws_ses_domain_identity.ses_domain.domain}"
#}
#
#resource "aws_route53_record" "ses_domain_amazonses_verification_record" {
#  count   = "${length(aws_ses_domain_dkim.example.dkim_tokens)}"
#  zone_id = "${aws_route53_zone.zone.zone_id}"
#  name    = "${element(aws_ses_domain_dkim.ses_domain.dkim_tokens, count.index)}._domainkey.example.com"
#  type    = "CNAME"
#  ttl     = "600"
#  records = ["${element(aws_ses_domain_dkim.ses_domain.dkim_tokens, count.index)}.dkim.amazonses.com"]
#}
