schema KcOpenIdGroupMembershipProtocolMapperWrapper:
    _claimName: str
    _clientScopeId: str
    _keycloakInstance: KeycloakInstance
    _name: str
    _projectName: str

    managedResource: ManagedResource {
        apiVersion = "openidgroup.keycloak.crossplane.io/v1alpha1"
        kind = "GroupMembershipProtocolMapper"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-roject" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectName
        }
        spec.forProvider.addToAccessToken = True
        spec.forProvider.addToIdToken = True
        spec.forProvider.addToUserinfo = True
        spec.forProvider.claimName = _claimName
        spec.forProvider.clientScopeId = _clientScopeId
        spec.forProvider.fullPath = False
        spec.forProvider.name = "groups"
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstance)
    }
    usages: [Usage] = []

