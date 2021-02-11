#!/usr/bin/env bash
set -o pipefail

# ./deploy.sh number1 1231546131 westeurope subscriptionid 1.17.7


export deploymentname="$1" # deployment name REQUIRED
export env_config="$2" # environmetn config file
export location="$3" # azure region OPTIONAL
export subscriptionid="$4" # subscription id OPTIONAL
export akssubnetid="$5" # subnet id of the aks subnet
export gwsubnetid="$6" # subnet id of the appgw subnet


echo "deploymentname: $deploymentname"
echo "env_config: $env_config"
echo "location: $location"
echo "subscriptionid: $subscriptionid"
echo "akssubnetid: $akssubnetid"
echo "gwsubnetid: $gwsubnetid"

if [ "$deploymentname" == "" ]; then
echo "No deploymentname provided - aborting"
exit 0;
fi

if [[ $deploymentname =~ ^[a-z0-9]{3,6}$ ]]; then
    echo "Deployment $deploymentname name is valid"
else
    echo "Deployment $deploymentname name is invalid - only numbers and lower case min 3 and max 6 characters allowed - aborting"
    exit 0;
fi

if [ "$location" == "" ]; then
location="northeurope"
echo "No location provided - defaulting to $location"
fi

if [ "$subscriptionid" == "" ]; then
subscriptionid=$(az account show --query id -o tsv)
echo "No subscriptionid provided defaulting to $subscriptionid"
else
az account set --subscription $subscriptionid
fi

tenantid=$(az account show --query tenantId -o tsv)

if [ ! "$env_config" == "" ]; then
   if [ -f $env_config ]; then
   echo "Provided file name $env_config found"
   else
      if [ -f "$(pwd)/config/$env_config.tfvars" ]; then
         echo "Found relative path $(pwd)/config/$env_config.tfvars"
         env_config=$(echo "found relative path $(pwd)/config/$env_config.tfvars")
      else
         echo "Found no relative path $(pwd)/config/$env_config.tfvars" 
         env_config = ""
      fi
   fi
fi

if [ "$env_config" == "" ]; then
echo "No env name provided"
let i=0 
for path in ./config/*.tfvars
do
   let i=$i+1 
   echo "$i $path"
done

echo "Please select a file by number"
read -n 1 config_file_id
echo ""

let j=0 
for path in ./config/*.tfvars
do
   let j=$j+1 
   if [ "$j" == "$config_file_id" ]; then
      env_config=$path
   fi
done
fi

if [ "$env_config" == "" ]; then
   echo "No env_config found - aborting"
   exit 0;
fi

echo "This script will create an environment for $deploymentname in $location using $env_config"
configfilename="${env_config##*/}"
configname=`echo "$configfilename" | cut -d'.' -f1`

TERRAFORM_DEPLOYMENT_NAME="$deploymentname$configname"
TERRAFORM_STORAGE_NAME="t$deploymentname$configname$location"
TERRAFORM_STATE_RESOURCE_GROUP_NAME="state$deploymentname$configname$location"

echo -e "TERRAFORM_DEPLOYMENT_NAME=$deploymentname$configname"
echo -e "TERRAFORM_STORAGE_NAME=$deploymentname$configname$location"
echo -e "TERRAFORM_STATE_RESOURCE_GROUP_NAME=state$deploymentname$configname$location"

echo "Creating terraform state storage..."
TFGROUPEXISTS=$(az group show --name $TERRAFORM_STATE_RESOURCE_GROUP_NAME --query name -o tsv --only-show-errors)
if [ "$TFGROUPEXISTS" == $TERRAFORM_STATE_RESOURCE_GROUP_NAME ]; then 
echo "Terraform storage resource group $TERRAFORM_STATE_RESOURCE_GROUP_NAME exists"
else
echo "Creating terraform storage resource group $TERRAFORM_STATE_RESOURCE_GROUP_NAME..."
az group create -n $TERRAFORM_STATE_RESOURCE_GROUP_NAME -l $location --output none
fi

TFSTORAGEEXISTS=$(az storage account show -g $TERRAFORM_STATE_RESOURCE_GROUP_NAME -n $TERRAFORM_STORAGE_NAME --query name -o tsv)
if [ "$TFSTORAGEEXISTS" == $TERRAFORM_STORAGE_NAME ]; then 
echo "Terraform storage account $TERRAFORM_STORAGE_NAME exists"
TERRAFORM_STORAGE_KEY=$(az storage account keys list --account-name $TERRAFORM_STORAGE_NAME --resource-group $TERRAFORM_STATE_RESOURCE_GROUP_NAME --query "[0].value" -o tsv)
else
echo "Creating terraform storage account $TERRAFORM_STORAGE_NAME..."
az storage account create --resource-group $TERRAFORM_STATE_RESOURCE_GROUP_NAME --name $TERRAFORM_STORAGE_NAME --location $location --sku Standard_LRS --output none
TERRAFORM_STORAGE_KEY=$(az storage account keys list --account-name $TERRAFORM_STORAGE_NAME --resource-group $TERRAFORM_STATE_RESOURCE_GROUP_NAME --query "[0].value" -o tsv)
az storage container create -n tfstate --account-name $TERRAFORM_STORAGE_NAME --account-key $TERRAFORM_STORAGE_KEY --output none
fi

if [ "$kubernetes_version" == "" ]; then
echo "Getting latest aks supporte version..."
KUBERNETES_VERSION=$(az aks get-versions -l $location --query 'orchestrators[?default == `true`].orchestratorVersion' -o tsv)
echo "Found AKS version $KUBERNETES_VERSION"
fi

echo "Initialzing terraform state storage..."

terraform init -backend-config="storage_account_name=$TERRAFORM_STORAGE_NAME" -backend-config="container_name=tfstate" -backend-config="access_key=$TERRAFORM_STORAGE_KEY" -backend-config="key=codelab.microsoft.tfstate" ./environment

echo "Planning terraform..."
terraform plan -out $TERRAFORM_DEPLOYMENT_NAME-out.plan -var-file "config/$configname.tfvars" -var="tenant_id=$tenantid" -var="resource_group_name=$deploymentname" -var="deployment_name=$deploymentname" -var="location=$location" -var="subscription_id=$subscriptionid" -var="aks_subnet_id=$akssubnetid" ./environment

# terraform plan -out $TERRAFORM_DEPLOYMENT_NAME-out.plan -var-file "config/$configname.tfvars" -var="tenant_id=$tenantid" -var="resource_group_name=$deploymentname" -var="deployment_name=$deploymentname" -var="location=$location" -var="subscription_id=$subscriptionid" -var="gw_subnet_id=$gwsubnetid" -var="aks_subnet_id=$akssubnetid" ./environment

if [ -f $TERRAFORM_DEPLOYMENT_NAME-out.plan ]; then
   echo "Running terraform apply..."
   terraform apply $TERRAFORM_DEPLOYMENT_NAME-out.plan
else
   echo "Skipping terraform apply due to error"
fi