# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/EqualExpertsMicroDC/terraform-stacks/blob/master/LICENSE
#

variable "account"           { }
variable "domain"            { }
variable "kubernetes_api_elb" { }
variable "project"           { }
variable "stack"             { default = "service" }

provider "aws" {
}

data "aws_region" "current" {
  current = true
}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "aws_global" {
  backend = "s3"

  config {
    bucket = "${var.project}-terraform-global"
    key    = "global-${var.account}.tfstate"
    region = "${data.aws_region.current.name}"
  }
}

data "terraform_remote_state" "aws_mgmt" {
  backend = "s3"

  config {
    bucket = "${var.project}-terraform-mgmt"
    key    = "mgmt.tfstate"
    region = "${data.aws_region.current.name}"
  }
}

module "iam_service_access" {
  source = "../../../modules/aws/iam_service_access"
  prod_account_id = "${data.terraform_remote_state.aws_global.prod_account_id}"
  nonprod_account_id = "${data.terraform_remote_state.aws_global.nonprod_account_id}"
}

module "kubernetes" {
  source                  = "../../../modules/aws/kubernetes"
  environment = "${terraform.workspace}"
  public_zone_id = "${data.terraform_remote_state.aws_global.zone_id}"
  kubernetes_api_elb = "${var.kubernetes_api_elb}"
}


# Zone IDs
output "public_zone_id"   { value = "${data.terraform_remote_state.aws_global.zone_id}" }
