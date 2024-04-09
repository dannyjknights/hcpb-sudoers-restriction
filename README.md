# HashiCorp Vault Dynamic SSH Credential Injection for Boundary sessions - Sudoer Restriction for SSH

![HashiCorp Boundary Logo](https://www.hashicorp.com/_next/static/media/colorwhite.997fcaf9.svg)

## Overview

This repo demonstrates injected application credentials for SSH targets, using a combination of HashiCorp Boundary and HashiCorp Vault. This deployment demonstrates how you can achieve certificate management at scale, whilst being able to add an additional level of control to what each user can access, when they successfully SSH onto the device.

## SSH Credential Injection and sudoer restriction

The SSH Credential Injection and sudoer restriction example in this repo has been setup as follows:

1. Configure HCP Boundary.
2. Configure HCP Vault.
3. Deploy a Boundary Worker in a public network (currently set to eu-west-2)
4. Establish a connection between the Boundary Controller and the Boundary Worker.
5. Deploy a server instance in a public subnet and to trust Vault as the CA.
6. Create a user called "danny" on the server
7. Create a directory `/etc/demodir`
8. Create a text file called `testfile.txt` in the new directory
9. Create a `readonly_services` file in the `sudoers.d` directory giving "danny" read only access to the `/etc/demodir/*` directory
6. Configure Boundary to allow access to resources in the public network.
7. Create all the requisite Vault policies

<Note>The fact that this repo has a server resource residing in an public subnet and therefore having a public IP attached is not supposed to mimic a production environment. This is purely to demonstrate the integration between Boundary and Vault.</Note>

<Note>When you gain SSH access to the target, you will be unable to write to the directory or modify the testfile.txt file, therefore proving the new policy. This serves as a base to expand and build more fitting policies in your own envinronment. </Note>

Your HCP Boundary and Vault Clusters needs to be created prior to executing the Terraform code. For people new to HCP, a trial can be utilised, which will give $50 credit to try, which is ample to test this solution.

## tfvars Variables

The following tfvars variables have been defined in a terraform.tfvars file.

- `boundary_addr`: The HCP Boundary address, e.g. "https://xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.boundary.hashicorp.
cloud"
- `auth_method_id`: "ampw_xxxxxxxxxx"                 
                 
- `password_auth_method_login_name`: = ""
- `password_auth_method_password`:   = ""
- `private_vpc_cidr`:                = ""
- `private_subnet_cidr`:             = ""
- `aws_vpc_cidr`:                    = ""
- `aws_subnet_cidr`:                 = ""
- `aws_access`:                      = ""
- `aws_secret`:                      = ""
- `vault_addr`:                      = ""
- `vault_token`:                     = ""