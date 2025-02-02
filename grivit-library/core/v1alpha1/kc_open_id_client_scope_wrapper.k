import core.v1alpha1 as core

schema KcOpenIdClientScopeWrapper:
    _targetKcProviderConfigWrapper: core.K8sProviderConfigWrapper
    _name: str
    _realmId: str
    _scopeName: str

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientScope"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.includeInTokenScope = True
        spec.forProvider.name = _scopeName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = _targetKcProviderConfigWrapper.managedResource.metadata.name
    }
    usages: [Usage] = []

    getClientScopeId: (any) -> str = lambda observedComposedResources: any -> str {
        _clientScopeId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientScopeId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _clientScopeId
    }

