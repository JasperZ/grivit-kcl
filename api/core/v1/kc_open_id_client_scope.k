schema KcOpenIdClientScope:
    _controlPlaneKcProviderConfigName: str
    _name: str
    _realmId: str
    _scopeName: str

    managedResource: CpManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientScope"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.includeInTokenScope = True
        spec.forProvider.name = _scopeName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [CpUsage] = []

