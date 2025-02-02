schema KcOpenIdClientServiceAccountRole:
    _clientId: str
    _name: str
    _serviceAccountUserId: str
    _realmId: str
    _roleName: str
    _targetKcProviderConfigWrapper: KcProviderConfigWrapper

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientServiceAccountRole"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.clientId = _clientId
        spec.forProvider.serviceAccountUserId = _serviceAccountUserId
        spec.forProvider.realmId = _realmId
        spec.forProvider.role = _roleName
        spec.providerConfigRef.name = _targetKcProviderConfigWrapper.managedResource.metadata.name
    }
    usages: [Usage] = []

