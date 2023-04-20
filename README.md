# Terraform Dynamic Credential Injection using Vault

## TFC Setup

On Terraform, all you need to do is create a VCS-Backed Workspace, and connect it to the infra/ directory. 

Then configure the Variables as shown below, filling in your VaultAddress/Namespace/Role. 

![image](https://user-images.githubusercontent.com/8341286/233312425-6b0d4337-f7b7-438b-9549-daa52394b627.png)

## Vault Setup
You will need a Vault cluster which is acessible by your Terraform instance. For this example I used a development size cluster on (HCP Vault)[https://portal.cloud.hashicorp.com/].

In the trust/variables.tf file you then need to enter your Terraform Organization, Project, and Workspace. If you wish to enable multiple workspaces to use the same role, wildcards can be used for Projects and Workspaces. 
(Workload Identity JWT Reference)[https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/workload-identity-tokens]: Here you can see how the user_claim can be modified to allow for different levels of granularity in the identity of the JWT. The Default, and most granular option, providing the highest level of Auditability is terraform_full_workspace.

You will need root aws credentials with the ability to creat IAM Accounts to configure the AWS Secrets engine. These can be rotated transparently afterwards.