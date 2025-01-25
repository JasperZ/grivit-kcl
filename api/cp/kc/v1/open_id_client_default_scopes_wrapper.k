import api.cp.core.v1 as cpCore

schema OpenIdClientDefaultScopesWrapper:
    _additionalScopes: [str] = []
    _controlPlaneKcProviderConfigName: str
    _clientId: str
    _name: str
    _realmId: str

    managedResource: cpCore.ManagedResource {
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
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [cpCore.Usage] = []

