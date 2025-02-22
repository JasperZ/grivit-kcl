schema KcOpenIdClientDefaultScopesWrapper:
    _additionalScopes: [str] = []
    _clientId: str
    _instanceName: str
    _name: str
    _projectNamespace: str
    _realmId: str

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
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = "${_projectNamespace}-${_instanceName}-${_realmId}-kc"
    }
    usages: [Usage] = []

