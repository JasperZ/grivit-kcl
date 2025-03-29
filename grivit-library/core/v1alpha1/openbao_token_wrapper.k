schema OpenBaoTokenWrapper:
    _name: str
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _projectName: str
    _projectNamespace: str
    _tokenDisplayName: str
    _tokenPolicies: [str]
    _tokenRenewable: bool = True
    _tokenRenewIncrement: int = 86400
    _tokenRenewMinLease: int = 43200
    _tokenRoleName: str
    _tokenTtl: str = "24h"


    managedResource: ManagedResource {
        apiVersion = "vault.vault.upbound.io/v1alpha1"
        kind = "Token"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.displayName = _tokenDisplayName
        spec.forProvider.policies = _tokenPolicies
        spec.forProvider.renewable = _tokenRenewable
        spec.forProvider.renewIncrement = _tokenRenewIncrement
        spec.forProvider.renewMinLease = _tokenRenewMinLease
        spec.forProvider.roleName = _tokenRoleName
        spec.forProvider.ttl = _tokenTtl
        spec.writeConnectionSecretToRef.name = _name
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
    }
    usages: [Usage] = []

