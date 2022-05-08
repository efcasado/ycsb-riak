terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.2.0"
    }
  }

  required_version = "1.1.8"
}

provider "scaleway" {
  zone   = "fr-par-1"
  region = "fr-par"
}

variable "project_id" {
  type        = string
  description = "Your project ID."
}

variable "instance_count" {
  default = "1"
}

resource "scaleway_account_ssh_key" "main" {
  project_id = var.project_id
  name        = "main"
  public_key = file("${path.module}/.ssh/id_rsa.pub")
}

resource "scaleway_instance_ip" "riak" {
  count = var.instance_count

  project_id = var.project_id
}

resource "scaleway_instance_security_group" "riak" {
  project_id              = var.project_id
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = "22"
  }

  inbound_rule {
    action = "accept"
    port   = "8087"
  }

  inbound_rule {
    action = "accept"
    port   = "8098"
  }

  inbound_rule {
    action = "accept"
    port   = "4369"
  }

  inbound_rule {
    action = "accept"
    port_range   = "6000-7023"
  }

}

resource "scaleway_instance_server" "riak" {
  count = var.instance_count

  project_id = var.project_id
  type       = "DEV1-S"
  image      = "ubuntu_focal"

  tags = ["riak", "riak_${count.index + 1}"]

  ip_id = scaleway_instance_ip.riak[count.index].id

  security_group_id = scaleway_instance_security_group.riak.id
}

output "instance_ip_addr" {
  value = scaleway_instance_ip.riak
}
