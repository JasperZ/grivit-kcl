schema KcOpenIdClientDefaultScopesWrapper:
    _additionalScopes: [str] = []
    _clientId: str
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectNamespace: str
    _realmId: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientDefaultScopes"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            "keycloak-instance" = _instanceName
            "keycloak-instance-owner-roject" = _instanceOwnerProjectName
            "keycloak-realm-id" = _realmId
            "project" = _projectNamespace
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
        spec.providerConfigRef.name = kcProviderConfigName(_projectNamespace, _instanceOwnerProjectName, _instanceName, _realmId)
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

