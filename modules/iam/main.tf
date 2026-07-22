# Read-only reviewer user. Hand-scoped to exactly what is needed to inspect the
# deployment — NOT the broad managed ReadOnlyAccess. Built from a map of
# statements via a dynamic block so each concern is one entry.

locals {
  reviewer_statements = {
    InspectCompute = [
      "ec2:DescribeInstances",      # app + jenkins boxes and their state
      "ec2:DescribeSecurityGroups", # verify SG rules (open-port review)
      "ec2:DescribeAddresses",      # see the Elastic IPs
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables", # confirm private subnets have no IGW route
    ]
    InspectDatabase = [
      "rds:DescribeDBInstances", # verify RDS is private + encrypted
      "rds:DescribeDBSubnetGroups",
    ]
    InspectLogsAndMetrics = [
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics",
      "logs:DescribeLogGroups",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_user" "reviewer" {
  name = "${var.project}-reviewer"
  tags = merge(var.tags, { Purpose = "read-only task review" })
}

# Console login (id = username, password = generated). Terraform stores the
# initial password in state (sensitive) — retrieve via `terraform output`.
resource "aws_iam_user_login_profile" "reviewer" {
  user                    = aws_iam_user.reviewer.name
  password_length         = 20
  password_reset_required = false
}

data "aws_iam_policy_document" "reviewer" {
  dynamic "statement" {
    for_each = local.reviewer_statements
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = statement.value
      resources = ["*"] # Describe*/Get* calls don't support resource scoping
    }
  }
}

resource "aws_iam_user_policy" "reviewer" {
  name   = "${var.project}-reviewer-readonly"
  user   = aws_iam_user.reviewer.name
  policy = data.aws_iam_policy_document.reviewer.json
}

resource "aws_iam_access_key" "reviewer" {
  user = aws_iam_user.reviewer.name
}
