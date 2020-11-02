# Environment with shared responsibility

## Shared resources:
Initial deployment:
- VNET
- Log Analytics
- KeyVaultInfra

## Dedicated team environment:
- AKS Identity
- KeyVaultEncryptionKey in KeyVaultInfra
- DiskEncryptionSet 
- DiskEncryptionSet Identity
- AKS
- Subnet in VNET /27
- ApplicationKeyVault
- ApplicationKeyVault Identity
- Log Analytics Space Identity