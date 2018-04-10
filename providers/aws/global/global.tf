# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#
variable "account"            { }
variable "domain"             { }
variable "project"            { }
variable "prod_account_id"    { }
variable "nonprod_account_id" { }

provider "aws" {
}

provider "aws" {
  alias  = "west"
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

module "ssm_params" {
  source = "../../../modules/aws/ssm_params"
  domain = "${var.domain}"
}

module "iam_user_groups" {
  source = "../../../modules/aws/iam_user_groups"
}

module "iam_cross_account_access" {
  source             = "../../../modules/aws/iam_cross_account_access"
  prod_account_id    = "${var.prod_account_id}"
  nonprod_account_id = "${var.nonprod_account_id}"
  account            = "${var.account}"
}

module "cloudtrail" {
  source  = "../../../modules/aws/cloudtrail"
  project = "${var.project}"
  account = "${var.account}"
}

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

resource "aws_route53_zone" "zone" {
  name    = "${var.domain}"
  comment = "${var.domain} public zone - Managed by Terraform"
}

resource "aws_dynamodb_table" "terraform-lock" {
  name           = "${var.project}-terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name        = "${var.project}-terraform-lock"
  }
}


module "global_state_bucket" {
  account        = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "global"
  prod_account_id = "${var.prod_account_id}"
}

module "mgmt_state_bucket" {
  account        = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "mgmt"
  prod_account_id = "${var.prod_account_id}"
}

module "service_state_bucket" {
  account        = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "service"
  prod_account_id = "${var.prod_account_id}"
}

module "vpcpeering_state_bucket" {
  account        = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "vpcpeering"
  prod_account_id = "${var.prod_account_id}"
}

resource "aws_s3_bucket" "kops_state_bucket" {
  bucket = "${var.project}-${var.account}-kops"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix = "/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags {
    Name    = "${var.project}-${var.account}-kops"
    Project = "${var.project}"
  }
}

output "prod_account_id" { value = "${var.prod_account_id}" }
output "nonprod_account_id" { value = "${var.nonprod_account_id}" }
output "mgmt_state_bucket" { value = "${module.mgmt_state_bucket.aws-s3-bucket-state-bucket-id}" }
output "zone_id"         { value = "${aws_route53_zone.zone.zone_id}" }
output "zone_domain"     { value = "${aws_route53_zone.zone.name}" }
output "availability_zones" { value = "${data.aws_availability_zones.available.names}" }
