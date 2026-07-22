# Ubuntu 22.04 LTS (Jammy), Canonical's official AMIs (owner 099720109477).
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Two instances (app, jenkins) from one block via for_each.
resource "aws_instance" "this" {
  for_each = var.instances

  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type
  subnet_id     = var.subnet_id
  key_name      = local.key_name

  # lookup() picks the SG for this instance's role; SG map is keyed by role.
  vpc_security_group_ids = [lookup(var.security_group_ids, each.value.role)]

  # Per-role bootstrap script chosen by filename via templatefile().
  user_data = templatefile(
    "${path.module}/templates/${each.value.role}.sh.tftpl",
    { jenkins_port = var.jenkins_port }
  )

  root_block_device {
    volume_size = each.value.root_gb
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${each.key}"
    Role = each.value.role
  })
}

# One Elastic IP per instance — same for_each keys keep them paired.
resource "aws_eip" "this" {
  for_each = aws_instance.this
  instance = each.value.id
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.project}-${each.key}-eip" })
}
