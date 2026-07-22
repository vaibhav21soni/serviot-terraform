# One SG per entry in var.security_groups (for_each). Ingress rules are
# expanded with a dynamic block from each SG's rule list — no repeated ingress
# stanzas, add a rule to the map and it appears.

resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = "${var.project}-${each.key}-sg"
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${each.key}-sg" })
}
