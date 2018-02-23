# Released under Apache licence v2.0 - Copyright and license notices must be preserved.
# See the LICENCE file at the top-level directory of this repo or at
# https://github.com/microdc/terraform-stacks/blob/master/LICENSE
#

# Network
estate_cidr = "10.64.0.0/10"
vpc_cidr    = { dev   = "10.67.0.0/16"
                test  = "10.77.0.0/16"
                stage = "10.87.0.0/16"
                prod  = "10.97.0.0/16" }

