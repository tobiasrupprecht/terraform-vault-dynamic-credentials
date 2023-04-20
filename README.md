# Terraform Dynamic Credential Injection using Vault
This is a tutorial focusing on the Vault Integration of the (Dynamic Credentials)[https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration] feature in Terraform Cloud. At the time of writing, Terraform Enterprise only supports the K/V configuration in this example. 

## Vault Setup

It makes sense to configure Vault first, as it will allow the Terraform Configuration to immediately work. 

You will need a Vault cluster which is acessible by your Terraform instance. For this example I used a development size cluster on (HCP Vault)[https://portal.cloud.hashicorp.com/].

In the trust/variables.tf file you then need to enter your Terraform Organization, Project, and Workspace. If you wish to enable multiple workspaces to use the same role, wildcards can be used for Projects and Workspaces. 
(Workload Identity JWT Reference)[https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens]: Here you can see how the user_claim can be modified to allow for different levels of granularity in the identity of the JWT. The Default, and most granular option, providing the highest level of Auditability is terraform_full_workspace.

You will need root aws credentials with the ability to creat IAM Accounts to configure the AWS Secrets engine. These can be rotated transparently afterwards.

Once all Variables are configured, configure the Vault address and token as environmental variables and apply the configuration within 

'''
cd trust/
export VAULT_ADDR=https://VAULT_ADDRESS_GOES_HERE:8200
export VAULT_TOKEN=VAULT_TOKEN_GOES_HERE
terraform init
terraform apply
'''

## TFC Setup

On Terraform, all you need to do is create a VCS-Backed Workspace, and connect it to the infra/ directory. 

Then configure the Variables as shown below, filling in your VaultAddress/Namespace/Role. 

![image](https://user-images.githubusercontent.com/8341286/233312425-6b0d4337-f7b7-438b-9549-daa52394b627.png)

Once the VCS Repo is connected, and the Variables configured, a run can be started. During the run, terraform will connect to Vault and fetch the credentials neede to configure the provider via the datasources. 

