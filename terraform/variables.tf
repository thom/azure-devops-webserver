variable "location" {
  type        = string
  description = "Region resources are created in"
  default     = "eastus"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default = {
    dept        = "Engineering"
    environment = "Production"
    project     = "Udacity Cloud DevOps using Microsoft Azure Nanodegree Program: Deploying a Web Server in Azure"
    createdby   = "Terraform"
  }
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
}

variable "project" {
  type    = string
  description = "Project name appended to resource names"
  default = "udacity-web-server"
}