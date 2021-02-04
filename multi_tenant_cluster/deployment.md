# Deployment of multi-tenant AKS cluster

This script will configure and deploy:
- Azure KeyVault
- Disk Encryption Set
- Log Analytics Workspace
- Azure Container Registry
- Azure Kubernetes Cluster
- Azure Application Gateway
- [Application Gateway Ingress Controller](https://github.com/Azure/application-gateway-kubernetes-ingress) via aks addon

Deployment can be triggered with the `deploy.sh` script

Attention: You need to specify an aad group aks_admin_object_id in the `env_config' file and the deployment user needs to be a member of this group - otherwise the helm deployment will fail

This script assumes that there is already a vnet deployed and that you have owner priviledges to configure approprate permissions on the vnet.

If not present this is how you can create a vnet
```

az group create -n $DEPLOYMENT_NAME-vnet -l $LOCATION
az network vnet create -g $DEPLOYMENT_NAME-vnet -n $DEPLOYMENT_NAME --address-prefixes 10.0.0.0/20

az network vnet subnet create -g $DEPLOYMENT_NAME-vnet --vnet-name $DEPLOYMENT_NAME -n gwsubnet --address-prefix 10.0.1.0/24
az network vnet subnet create -g $DEPLOYMENT_NAME-vnet --vnet-name $DEPLOYMENT_NAME -n akssubnet --address-prefix 10.0.2.0/24 --service-endpoints Microsoft.Sql Microsoft.AzureCosmosDB Microsoft.KeyVault Microsoft.Storage

GW_SUBNET_ID=$(az network vnet subnet show -g $DEPLOYMENT_NAME-vnet --vnet-name $DEPLOYMENT_NAME -n gwsubnet --query id -o tsv)
AKS_SUBNET_ID=$(az network vnet subnet show -g $DEPLOYMENT_NAME-vnet --vnet-name $DEPLOYMENT_NAME -n akssubnet --query id -o tsv)

```

If you already have a vnet please fill the following variables with the resource id for the application gateway and aks subnets

```
GW_SUBNET_ID="/subscriptions/SUBSCRIPTIONID/resourceGroups/depl30-vnet/providers/Microsoft.Network/virtualNetworks/depl30/subnets/gwsubnet"
AKS_SUBNET_ID="/subscriptions/SUBSCRIPTIONID/resourceGroups/depl30-vnet/providers/Microsoft.Network/virtualNetworks/depl30/subnets/akssubnet"

```

```
chmod +x ./deploy.sh 
DEPLOYMENT_NAME="depl30" # name of the deployment lower case unique name
ENV_CONFIG="dev" # environment config - alternative provide absolut or relative path to config file ./config/dev.tfvars
LOCATION="northeurope" # datacenter location - default is northeurope
SUBSCRIPTION_ID=$(az account show --query id -o tsv) # your subscription id
./deploy.sh $DEPLOYMENT_NAME $ENV_CONFIG $LOCATION $SUBSCRIPTION_ID $GW_SUBNET_ID $AKS_SUBNET_ID

```

Naming conventions for all resources are maintained in main.tf


## Connect to your cluster

```
KUBE_GROUP=
KUBE_NAME=
az aks get-credentials -g $KUBE_GROUP -n $KUBE_NAME
```
