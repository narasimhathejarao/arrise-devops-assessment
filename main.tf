terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Task 1: Provision 5 instances from a single map input using for_each
resource "aws_instance" "nodes" {
  for_each = var.instances_config

  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size
    iops                  = contains(["io1", "io2"], each.value.root_volume_type) ? each.value.iops : null
    delete_on_termination = true
  }

  tags = {
    Name        = each.value.tags["Name"]
    Environment = each.value.tags["Environment"]
    Owner       = each.value.tags["Owner"]
  }

  # Lifecycle rule enforcing deletion protection on critical database node
  lifecycle {
    prevent_destroy = true
  }
}