import base64

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
    _tokenRoleName?: str
    _tokenTtl: str = "24h"
    _uses: [ManagedResource] = []

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
        if _tokenRoleName:
            spec.forProvider.roleName = _tokenRoleName
        spec.forProvider.ttl = _tokenTtl
        spec.writeConnectionSecretToRef.name = _name
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, "admin")
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

    getClientToken: (any) -> str = lambda observedComposedResources: any -> str {
        _clientToken: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientToken = str(base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails["attribute.client_token"]))

        _clientToken
    }