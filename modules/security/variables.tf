variable "project" { type = string }
variable "vpc_id" { type = string }

# Map of security groups to create. Each has a list of ingress rules that the
# dynamic block below expands. Keys become the SG lookup keys (e.g. "app",
# "jenkins").
variable "security_groups" {
  type = map(object({
    description = string
    ingress = list(object({
      description = string
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
