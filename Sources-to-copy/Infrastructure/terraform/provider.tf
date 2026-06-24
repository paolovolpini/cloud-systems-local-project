terraform {
    required_providers {
        multipass = {
            source = "larstobi/multipass"
            version = "~>1.4.3"
        }
    }
    backend "local" {
        path = pathexpand("~/tofu-gen/terraform.tfstate")
    }
}

provider "multipass" {}

