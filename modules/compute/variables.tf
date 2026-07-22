variable "project" { type = string }

# The set of instances to create, keyed by name. for_each walks this map, so
# adding a third box is one more entry — no copy-pasted resource blocks.
variable "instances" {
  type = map(object({
    role          = string # selects SG + user_data template ("app" | "jenkins")
    instance_type = string
    root_gb       = optional(number, 30)
  }))
}

variable "subnet_id" { type = string }

# Generate a key pair (default) or reuse an existing one.
variable "create_key_pair" {
  type    = bool
  default = true
}
variable "existing_key_name" {
  description = "Used only when create_key_pair = false."
  type        = string
  default     = ""
}

# role -> security group id (from the security module).
variable "security_group_ids" {
  type = map(string)
}

variable "jenkins_port" {
  type    = number
  default = 8443
}

variable "tags" {
  type    = map(string)
  default = {}
}
