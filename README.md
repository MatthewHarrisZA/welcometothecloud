# Welcome to the cloud
### Introduction

This repo is meant to be the home for a series of easy start scripts for adding scaffolding to a new repository (project) to get started provisioning resources.

### Before you begin

The way this works is by executing a remote script, similar to the installation of popular tools such as [Chocolatey](https://chocolatey.org/install). You should *never* do this unless you understand what the remote script does or *explicitly trust* the source.

Also note that this script is to be used for dev purposes only. It currently also only supports Windows machines.

### How to use

To get started run the following command in PowerShell (as administrator):

##### Pulumi

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/MatthewHarrisZA/welcometothecloud/master/pulumi/Initialize-Pulumi.ps1'))`

You will then be prompted with a series of inputs which will be used in the script to get things up and running.

### Pre-requsites

As part of the script it will need an Azure Key Vault to already be created and also an Azure storage account. You will also need to install PowerShell v5 or higher and install [Chocolatey](https://chocolatey.org/install).

### What does the script try to do?

##### Pulumi

1. Install Pulumi if it isn't installed already
2. Install Azure CLI if it isn't installed already
3. Set some ENV variables which will be used later by the Azure CLI
4. Try and detect if you are using Netskope and if you are then it will add the CA cert path to an ENV variable so that the Azure CLI does not reject the certificate.
5. Creates a folder called "devops" which will contain the actual Pulumi files.
6. Initializes a Pulumi project.
7. Restores Pulumi NPM packets.
8. Opens a Azure login dialog box so that you can authenticate and the script can continue in your security context.
9. Switches context to the sandbox subscription.
10. Creates a storage blob for for Pulumi backend.
11. Performs Pulumi login to Azure Storage as a backend instead of a the default which is Pulumi's offering.
12. Initializes  a Pulumi stack called "sandbox" which uses an Azure Key Vault Encryption Key to encrypt and decrypt secrets.
13. Creates some example variables including a secret (for demonstration purposes only since it it not used in the Pulumi script).
14. Replaces the default Pulumi example (which was created in step 6) with a better example that uses the variables we just created.