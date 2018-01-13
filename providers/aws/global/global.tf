# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#
variable "account"           { }
variable "domain"            { }
variable "project"           { }
variable "stack"             { }
variable "prod_account_id"   { }
variable "nonprod_account_id"   { }

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

module "ses" {
  source  = "../../../modules/aws/ses"
  domain  = "${var.domain}"
  zone_id = "${aws_route53_zone.zone.zone_id}"
}

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
  acount         = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "global"
  prod_acount_id = "${var.prod_account_id}"
}

module "mgmt_state_bucket" {
  acount         = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "mgmt"
  prod_acount_id = "${var.prod_account_id}"
}

module "service_state_bucket" {
  acount         = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "service"
  prod_acount_id = "${var.prod_account_id}"
}

module "vpcpeering_state_bucket" {
  acount         = "${var.account}"
  source         = "../../../modules/aws/state_bucket"
  project        = "${var.project}"
  stack          = "vpcpeering"
  prod_acount_id = "${var.prod_account_id}"
}

output "prod_account_id" { value = "${var.prod_account_id}" }
output "nonprod_account_id" { value = "${var.nonprod_account_id}" }
output "mgmt_state_bucket" { value = "${module.mgmt_state_bucket.aws-s3-bucket-state-bucket-id}" }
output "zone_id"         { value = "${aws_route53_zone.zone.zone_id}" }
output "zone_domain"     { value = "${aws_route53_zone.zone.name}" }
output "availability_zones" { value = "${data.aws_availability_zones.available.names}" }
