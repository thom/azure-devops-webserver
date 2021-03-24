# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Introduction

This project builds a scalable website deployment. It uses Packer to create a
server image, and Terraform to create a template for deploying a scalable
cluster of servers - with a load balancer to manage the incoming traffic.

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

### Create and manage tagging policy to enforce compliance

Create the tagging policy:

```bash
az policy definition create --name "tagging-policy" --description "This policy ensures that all indexed resources are tagged." --display-name "Deny indexed resources without tags" --metadata "version=1.0.0" --metadata "category=Tags" --mode "Indexed" --rules tagging-policy-rules.json
```

Apply the policy to ensure all indexed resources are tagged:

```bash
az policy assignment create --display-name "Deny indexed resources without tags" --name "tagging-policy-assignment" --policy "tagging-policy"
```

Make sure the policy has been assigned:

```bash
az policy assignment list
```

## Output

Your words here

## References

* [Quickstart: Create a policy assignment to identify non-compliant resources with Azure CLI](https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-azurecli)
* [Quickstart: Create a policy assignment to identify non-compliant resources using Terraform](https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-terraform)
* [Tutorial: Create and manage policies to enforce compliance](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage)
* [Tutorial: Manage tag governance with Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/govern-tags)
* [Assign policies for tag compliance](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-policies)
* [Creating Custom VM Images in Azure using Packer](https://microsoft.github.io/AzureTipsAndTricks/blog/tip201.html)
* [How to use Packer to create Linux virtual machine images in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/build-image-with-packer)
* [Create an Azure virtual machine scale set from a Packer custom image by using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-vm-scaleset-network-disks-using-packer-hcl)

## Requirements

Graded according to the [Project Rubric](https://review.udacity.com/#!/rubrics/2843/view).

## License

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
- Copyright 2021 © [Thomas Weibel](https://github.com/thom).
