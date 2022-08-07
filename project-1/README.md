# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

In this project, we will create a scalable web server in Azure.
It will be deployed on multiple virtual machine in Azure, behind a loadbalancer to ensure high availability.
We will do it in reproducible, fully IaaS manner. This is a good example of how to automate infrastructure in Azure.

### Getting Started

1. Clone this repository.
2. Have access to shell to run commands in, and some basic unix skills.

For easier reading I have split the main.tf file into multiple files with similar resources. All of them are in `./infrastructure/` directory.


### Dependencies

1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### 0. Azure CLI login

0.1. First of all, you need to login to your Azure account, as it is used to create all the resources.
0.2. Packer and Terraform also support using credentials from Azure CLI, so this saves us some hassle with passing credentials to our tools.

#### 1. Create and enforce tagging policy

We want to have a tag on all the resources we create, so we can easily find them later. This is often also a compliance requirement. Using a policy we can assure that all resources have a tag.
It would be also a good idea to have a structured tag convention and policies can also ensure this.

1.1. Login using `az login`
1.2. Create a policy definition using `az policy definition create --name "tagging-policy" --rules "./tagging-policy.json"`
1.3. Assign created policy to the subscription using `az policy assignment create --name "tagging-policy-assignment" --policy "tagging-policy" --scope "/subscriptions/<subscription-id>"`
1.4. To get subscription id use `az account show | jq .id`

#### 2. Create a resource group

Since we are going to use the same resource group for all our resources, we need to create it first. We can do it using Terraform, so Packer will have a resource group to create images in.

2.0 Change directory to `infrastructure`. Perform `terraform init` to download providers and prepare environment.
2.1 Issue the following command to create a resource group: `terraform apply --target="azurerm_resource_group.main"` in `infrastructure` directory. Approve with `yes`.

#### 3. Create image using packer

We would like to deploy servers from our own image. Firstly we have to build the image. This is done using Packer. Images are build and stored in Azure.

3.1. Issue command `packer build server.json` in main directory. It will create VM os disk image in Azure.

#### 4. Create the rest of infrastructure using Terraform

Now we can create all other infrastructure, including loadbalancer, servers, network and some auxiliary objects.
All of these are defined in Terraform files.

4.1. Use `terraform plan -out solution.plan` to create a plan.
4.2. You can review the plan using `terraform show solution.plan` to see what will be created.
4.3. Use `terraform apply solution.plan` to create the infrastructure. Again, approve with `yes`.
After few minutes all resources should be created automatically and terraform will output the public ip of loadbalancer.

#### 5. Destroy the environment

5.1 Don't forget to destroy the infrastructure using `terraform destroy`. You do not want to leave resources behind and pay for toy infrastructure.

### Output

We have created the following infrastructure:

- Resource group
- Loadbalancer
- VMs
- Virtual Network
- Subnet
- Image
- additional Data Disks for VMs
- http probes for probing if the server is up
- and some auxiliary resources, such as public IP, network security group, etc.

After applying the infrastructure, you can immediately see the web server running on the public ip. Cool, isn't it? :)

Our infrastructure is fully automated and reproducible. It can be stored as a template and deployed again in the future.
We can easily edit vars.tf file to change the number of VMs (`vm_count` variable) to scale it, change the image.

Our tools make infrastructure easier to mantain, deploy, reuse (eg. to create dev environments) and scale. Infrastructure can be stored in git and therefore undergo the same process of review, approval, rollback to past versions as the code.

That's the magic of Infrastructure as a Code, cloud and modern tools such as Packer and Terraform.

### Troubleshooting

Unfortunately this does not work for a reason:

Image created by packer does not run the web server as a daemon. `nohup busybox httpd -f -p 80 &` works only during image building process. To properly address this issue we should install web server such as apache or nginx and enable it to run after system boot using `systemctl enable nginx.service`.

`nohup busybox httpd -f -p 80 &` was specified in rubric, so I am leaving it as is in the `server.json` file.

Because of this I created a separate `nginx.json` file with the `nginx` web server installed and enabled.
You can redo the 3.1 step with `packer build --force nginx.json` to create the working image (`--force` is to rebuild the image even if it already exists).

Then you will have to redeploy the infrastructure to create VMs with the new image.
