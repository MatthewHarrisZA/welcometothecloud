# Welcome to the cloud
A series of easy start scripts for adding scaffolding to a new repository (project) to get started provisioning resources.

To get started run the following command in PowerShell (as administrator):

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/MatthewHarrisZA/welcometothecloud/master/pulumi/Initialize-Pulumi.ps1'))`