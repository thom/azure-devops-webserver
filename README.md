# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [Instructions](#instructions)
  - [Login with Azure CLI](#login-with-azure-cli)
  - [Create and manage tagging policy to enforce compliance](#create-and-manage-tagging-policy-to-enforce-compliance)
  - [Build Packer image](#build-packer-image)
- [Output](#output)
- [Clean-up](#clean-up)
- [References](#references)
- [Requirements](#requirements)
- [License](#license)

## Introduction

This project builds a scalable nginx deployment. It uses Packer to create a server image, and Terraform to create a template for deploying a scalable cluster of servers - with a load balancer to manage the incoming traffic.

## Getting Started

1. Clone this repository
2. Ensure you have all the dependencies
3. Follow the instructions below

## Dependencies

1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

## Instructions

### Login with Azure CLI

This project uses your Azure user and the Azure CLI to login and execute commands:

```bash
az login
```

Check [Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest) if you prefer using a service principal instead.

### Create and manage tagging policy to enforce compliance

Create the tagging policy:

```bash
az policy definition create \
    --name "policy-tagging" \
    --description "This policy ensures that all indexed resources are tagged." \
    --display-name "Deny indexed resources without tags" \
    --metadata "version=1.0.0" \
    --metadata "category=Tags" \
    --mode "Indexed" \
    --rules policies/policy-tagging-rules.json
```

Apply the policy to ensure all indexed resources are tagged:

```bash
az policy assignment create \
    --display-name "Deny indexed resources without tags" \
    --name "policy-assignment-tagging" \
    --policy "policy-tagging"
```

Make sure the policy has been assigned:

```bash
az policy assignment list
```

### Build Packer image

During the build process, Packer creates temporary Azure resources as it builds the source VM. To capture that source VM for use as an image, you must define a resource group. The output from the Packer build process is stored in this resource group.

```bash
az group create \
    --name udacity-web-server-rg-packer \
    --location eastus \
    --tags "dept=Engineering" \
    --tags "environment=Development" \
    --tags "project=Udacity Cloud DevOps" \
    --tags "createdby=CLI"
```

Build the image by specifying your Packer template file as follows:

```bash
packer build packer/server.json
```

Packer creates a new OS image called "udacity-web-server-image-ubuntu-nginx" in the `udacity-web-server-rg-packer` resource group.

Optionally you can now test the images created by Packer with `az vm create`:

```bash
az vm create \
    --resource-group udacity-web-server-rg-packer \
    --name vm-packer-test \
    --image udacity-web-server-image-ubuntu-nginx \
    --admin-username azureuser \
    --generate-ssh-keys \
    --tags "dept=Engineering" \
    --tags "environment=Test" \
    --tags "project=Udacity Cloud DevOps" \
    --tags "createdby=CLI"
```

To allow web traffic to reach your VM, open port 8080 from the Internet with `az vm open-port`:

```bash
az vm open-port \
    --resource-group udacity-web-server-rg-packer \
    --name vm-packer-test \
    --port 8080
```

## Output

TBD

## Clean-up

1. Destroy the Terraform resources:

   ```bash
   cd terraform
   terraform destroy
   ```

2. Delete the image generated with Packer:

   ```bash
   az image delete --name udacity-web-server-image-ubuntu-nginx --resource-group udacity-web-server-rg-packer
   ```

3. Delete the Packer resource group:

   ```bash
   az group delete --yes --name udacity-web-server-rg-packer
   ```

4. Delete the policy assignment:

   ```bash
   az policy assignment delete --name policy-assignment-tagging
   ```

5. Delete the policy definition:

   ```bash
   az policy definition delete --name policy-tagging
   ```

## References

- [Recommended abbreviations for Azure resource types](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Define your naming convention for Azure resources](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Quickstart: Create a policy assignment to identify non-compliant resources with Azure CLI](https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-azurecli)
- [Quickstart: Create a policy assignment to identify non-compliant resources using Terraform](https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-terraform)
- [Tutorial: Create and manage policies to enforce compliance](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage)
- [Tutorial: Manage tag governance with Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/govern-tags)
- [Assign policies for tag compliance](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-policies)
- [Creating Custom VM Images in Azure using Packer](https://microsoft.github.io/AzureTipsAndTricks/blog/tip201.html)
- [How to use Packer to create Linux virtual machine images in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)
- [Create an Azure virtual machine scale set from a Packer custom image by using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-vm-scaleset-network-disks-using-packer-hcl)
- [Terraform Style Conventions](https://www.terraform.io/docs/language/syntax/style.html)

## Requirements

Graded according to the [Project Rubric](https://review.udacity.com/#!/rubrics/2843/view).

## License

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2021 © [Thomas Weibel](https://github.com/thom).
