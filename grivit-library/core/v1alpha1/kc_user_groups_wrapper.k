schema KcUserGroupsWrapper:
    _keycloakInstance: KeycloakInstance
    _keycloakGroupIds: [str]
    _keycloakUserId: str
    _projectName: str
    _managedResourceName: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "user.keycloak.crossplane.io/v1alpha1"
        kind = "Groups"
        metadata.name = _managedResourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _managedResourceName
        }
        metadata.labels = {
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-roject" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectName
        }
        spec.forProvider.exhaustive = True
        spec.forProvider.groupIds = _keycloakGroupIds
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.forProvider.userId = _keycloakUserId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstance)
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_managedResourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_managedResourceName}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

