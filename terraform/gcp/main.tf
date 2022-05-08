terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.20.0"
    }
  }

  required_version = "1.1.8"
}

variable "project_id" {
  type        = string
  description = "Your project ID."
}

variable "instance_count" {
  default = "1"
}

provider "google" {
  credentials = file("credentials.json")

  region = "europe-north1"
  zone = "europe-north1-a"
  project = var.project_id
}

resource "google_compute_network" "riak" {
  name = "riak"
}

resource "google_compute_instance" "riak" {
  count        = var.instance_count
  name         = "riak-${count.index + 1}"
  machine_type = "f1-micro"

  tags = ["riak", "riak${count.index + 1}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "root:file(${path.module}/.ssh/id_rsa.pub)"
  }
}
