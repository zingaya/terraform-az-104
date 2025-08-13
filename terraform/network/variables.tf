variable "rg_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "subnet_name" { type = string }

# Pre-create NICs for web and SQL servers to avoid provisioning full VMs and reduce costs
# Define NICs to create with their subnet suffix
variable "nics" {
  type = map(object({
    subnet_suffix = string
    asgs          = list(string)  # list of ASG names per NIC
  }))
  default = {
    web1   = { subnet_suffix = "0", asgs = ["web_asg"] }
    web2   = { subnet_suffix = "0", asgs = ["web_asg"] }
    sql1   = { subnet_suffix = "0", asgs = ["sql_asg"] }
    sql2   = { subnet_suffix = "0", asgs = ["sql_asg"] }
    admin1 = { subnet_suffix = "1", asgs = [] }
  }
}
