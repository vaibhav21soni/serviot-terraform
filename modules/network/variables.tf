variable "project" { type = string }
variable "vpc_cidr" { type = string }

variable "azs" {
  description = "AZs to spread subnets across (>= 2 for RDS)."
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
