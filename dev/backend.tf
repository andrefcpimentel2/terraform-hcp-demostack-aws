# Using a single workspace:

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "emea-se-playground-2019"
    workspaces {
      name = "Andre-HCP-AWS-Demostack"
    }
  }
  }
