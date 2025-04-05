schema KcOpenIdClientServiceAccountRole:
    _clientId: str
    _keycloakInstance: KeycloakInstance
    _name: str
    _projectNamespace: str
    _roleName: str
    _serviceAccountUserId: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientServiceAccountRole"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-roject" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectNamespace
        }
        spec.forProvider.clientId = _clientId
        spec.forProvider.serviceAccountUserId = _serviceAccountUserId
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.forProvider.role = _roleName
        spec.providerConfigRef.name = kcProviderConfigName(_projectNamespace, _keycloakInstance)
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

