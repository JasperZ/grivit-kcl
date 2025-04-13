schema KcOpenIdGroupMembershipProtocolMapperWrapper:
    _claimName: str
    _clientScopeId: str
    _keycloakInstance: KeycloakInstance
    _name: str
    _projectName: str
    _uses: [ManagedResource] = []

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
    
    usages: [Usage] = [Usage {
        metadata.name = "${managedResource.metadata.name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${managedResource.metadata.name}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

