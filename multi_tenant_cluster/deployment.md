# Deployment of multi-tenant AKS cluster

This script will configure and deploy:
- Azure Virtual Network
- Log Analytics Workspace
- Azure Container Registry
- Azure Application Gateway
- Azure Kubernetes Cluster
- [AAD-Pod-Identity](https://github.com/Azure/aad-pod-identity) via helm
- [Traefik](https://github.com/traefik/traefik-helm-chart) via helm
- [Application Gateway Ingress Controller](https://github.com/Azure/application-gateway-kubernetes-ingress) via helm

Deployment can be triggered with the `deploy.sh` script

Attention: You need to specify an aad group aks_admin_object_id in the `env_config' file and the deployment user needs to be a member of this group - otherwise the helm deployment will fail

```
DEPLOYMENT_NAME="depl234" # name of the deployment lower case unique name
ENV_CONFIG="dev" # environment config - alternative provide absolut or relative path to config file ./config/dev.tfvars
LOCATION="northeurope" # datacenter location - default is northeurope
SUBSCRIPTION_ID=$(az account show --query id -o tsv) # your subscription id
./deploy.sh $DEPLOYMENT_NAME $ENV_CONFIG $LOCATION $SUBSCRIPTION_ID

```

Naming conventions for all resources are maintained in main.tf