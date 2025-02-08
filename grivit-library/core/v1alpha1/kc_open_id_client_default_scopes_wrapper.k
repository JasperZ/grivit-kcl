schema KcOpenIdClientDefaultScopesWrapper:
    _additionalScopes: [str] = []
    _clientId: str
    _name: str
    _realmId: str = None
    _targetKcProviderConfigWrapper: KcProviderConfigWrapper

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientDefaultScopes"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.clientId = _clientId
        spec.forProvider.defaultScopes = [
            "acr"
            "basic"
            "email"
            "profile"
            "roles"
            "web-origins"
        ] + _additionalScopes
        if _realmId != None:
            spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = _targetKcProviderConfigWrapper.managedResource.metadata.name
    }
    usages: [Usage] = []

