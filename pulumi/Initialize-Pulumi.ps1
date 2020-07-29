Write-Host "[INFO] Initialzing Pulumi starter content" -ForegroundColor Cyan

# Prerequisite check

try {
    choco --version | Out-Null
}
catch {
    Write-Host "[ERROR] This script requires Chocolatey to be installed. Visit https://chocolatey.org/install for more information." -ForegroundColor Red
    exit -1
}

# Install Pulumi

try {
    pulumi version | Out-Null
    $pulumiInstalled = $true
    Write-Host "[INFO] Pulumi already installed" -ForegroundColor Cyan
}
catch {
    $pulumiInstalled = $false
}

if($pulumiInstalled -eq $false) {
    try {
        choco install pulumi --force -y
    }
    catch {
        Write-Host "[ERROR] Failed to install Pulumi. Please attempt a manual installation by following instructions at https://www.pulumi.com/docs/get-started/install/." -ForegroundColor Red
    }
}

# Install Azure CLI

try {
    az version | Out-Null
    $azInstalled = $true
    Write-Host "[INFO] Azure CLI already installed" -ForegroundColor Cyan
}
catch {
    $azInstalled = $false
}

if($azInstalled -eq $false) {
    try {
        choco install azure-cli --force -y
    }
    catch {
        Write-Host "[ERROR] Failed to install Azure CLI. Please attempt a manual installation by following instructions at https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest." -ForegroundColor Red
    }
}

# Set environment variables

try {
    $azureStorageAccount = "st$($env:username)sandbox"
    setx AZURE_STORAGE_ACCOUNT $azureStorageAccount | Out-Null
    Write-Host "[INFO] Successfully set AZURE_STORAGE_ACCOUNT env variable to $azureStorageAccount" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Unable to set AZURE_STORAGE_ACCOUNT env variable to $azureStorageAccount" -ForegroundColor Red
    exit -1
}

try {
    $azureStorageKey = Read-Host "Please enter the Azure Storage Key provided in your 'Welcome to the Cloud starter pack'"
    setx AZURE_STORAGE_KEY $azureStorageKey | Out-Null
    Write-Host "[INFO] Successfully set AZURE_STORAGE_KEY env variable to $azureStorageKey" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to set AZURE_STORAGE_KEY env variable to $azureStorageKey" -ForegroundColor Red
    exit -1
}

try {
    setx AZURE_KEYVAULT_AUTH_VIA_CLI true | Out-Null
    Write-Host "[INFO] Successfully set AZURE_KEYVAULT_AUTH_VIA_CLI env variable to true" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to set AZURE_KEYVAULT_AUTH_VIA_CLI env variable to true" -ForegroundColor Red
    exit -1
}

$netscopeCertFilePath = "$($env:ProgramData)\Netskope\STAgent\download\nscacert.pem"

if(Test-Path $netscopeCertFilePath) {
    Write-Host "[INFO] NetSkope certificate succesfully located" -ForegroundColor Cyan
} else {
    Write-Host "[ERROR] Netskope certificate could not be found at '$netscopeCertFilePath'" -ForegroundColor Red
    exit -1
}

try {
    setx REQUESTS_CA_BUNDLE $netscopeCertFilePath | Out-Null
    Write-Host "[INFO] Successfully set REQUESTS_CA_BUNDLE env variable to $netscopeCertFilePath" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to set REQUESTS_CA_BUNDLE env variable to $netscopeCertFilePath" -ForegroundColor Red
    exit -1
}

# Create devops folder

try {
    if(Test-Path "devops") {
        Write-Host "[ERROR] 'devops' folder already exists. To reinitialize this project please completly remove the 'devops' folder." -ForegroundColor Red
        exit -1
    }
    else {
        New-Item -Name "devops" -ItemType "directory" | Out-Null
        Write-Host "[INFO] Successfully created 'devops' folder" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "[ERROR] Failed to create 'devops' folder" -ForegroundColor Red
    exit -1
}

# Initialize Pulumi

Set-Location -Path "devops"

$pulumiProjectName = Read-Host "Enter the name of this project (for Pulumi)"

$pulumiProjectDescription = Read-Host "Enter a description for this project (for Pulumi)"

try {
    pulumi new azure-typescript -g -n $pulumiProjectName -d $pulumiProjectDescription -y | Out-Null
    Write-Host "[INFO] Successfully initialised new Typescript Pulumi project with Azure provider" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to initialise new Typescript Pulumi project with Azure provider" -ForegroundColor Red
    exit -1
}

# Install the NPM packages needed by Pulumi

try {
    npm install
    Write-Host "[INFO] Successfully installed required NPM packages for Pulumi" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to install required NPM packages for Pulumi" -ForegroundColor Red
    exit -1
}

# Log on to Azure

try {
    Write-Host "[INFO] Logging in to Azure CLI, your browser will open to authenticate you now..." -ForegroundColor Cyan
    az login
    Write-Host "[INFO] You have succesfully authenticated using the Azure CLI" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to login using the Azure CLI. Try running the following command to login manually: az login" -ForegroundColor Red
    exit -1
}

# Switch subscription

$azureSubscription = "DERAZSandbox-Game Technology"

try {
    az account set --subscription $azureSubscription
    Write-Host "[INFO] Azure CLI context succesfully set to '$azureSubscription' subscription" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to set Azure CLI context to '$azureSubscription' subscription" -ForegroundColor Red
    exit -1
}

# Create Azure Storage blob for Pulumi backend

$pulumiBackendContainerName = $pulumiProjectName.ToLower().Trim().Replace(' ', '')

try {
    az storage container create --name $pulumiBackendContainerName
    Write-Host "[INFO] Succesfully created AZ Storage Account Container called $pulumiBackendContainerName for storing Pulumi backend remotely" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to create AZ Storage Account Container called $pulumiBackendContainerName for storing Pulumi backend remotely" -ForegroundColor Red
    exit -1
}

# Perform Pulumi login using Azure Storage Account container

$pulumiCloudUrl = "azblob://$pulumiBackendContainerName"

try {
    pulumi login --cloud-url $pulumiCloudUrl
    Write-Host "[INFO] Succesfully connected to remote Pulumi backend" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to connect to remote Pulumi backend" -ForegroundColor Red
    exit -1
}

# Initialize Pulumi sandbox stack (for development)

$pulumiSecretsProvider = "azurekeyvault://kv-$($env:UserName)-sandbox.vault.azure.net/keys/pulumi"

try {
    pulumi stack init sandbox --secrets-provider=$pulumiSecretsProvider
    Write-Host "[INFO] Succesfully initialized Pulumi 'sandbox' stack" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to initialize Pulumi 'sandbox' stack" -ForegroundColor Red
    exit -1
}

# Set example config for sandbox stack

try {
    $resourceGroupName = "rg-$($env:UserName)-sandbox"
    $dnsNameLabel = "example-$($env:UserName)"

    pulumi config set resourceGroupName $resourceGroupName
    pulumi config set containerServiceGroupName example
    pulumi config set containerName nyan
    pulumi config set containerImageName daviey/nyan-cat-web
    pulumi config set dnsNameLabel $dnsNameLabel
    
    Write-Host "[INFO] Succesfully set example config for sandbox stack" -ForegroundColor Cyan
}
catch {
    Write-Host "[ERROR] Failed to set example config for sandbox stack" -ForegroundColor Red
    exit -1
}

# Replace example index.ts file

Remove-Item -Path "index.ts" -force

$pulumiStarterIndexUri = "https://raw.githubusercontent.com/MatthewHarrisZA/welcometothecloud/master/pulumi/starter_index.ts"

Invoke-WebRequest -Uri $pulumiStarterIndexUri -OutFile "index.ts"

# Final message and instrcutions

Write-Host "Pulumi stack initialized. You are ready to start provisioning resources! Visit https://www.pulumi.com/docs/ for more information." -ForegroundColor Cyan