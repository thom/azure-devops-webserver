variable "tags" {
  type = map

  default = {
    dept        = "Engineering"
    environment = "Production"
    project     = "Udacity Cloud DevOps using Microsoft Azure Nanodegree Program: Deploying a Web Server in Azure"
    createdby   = "Terraform"
  }
}