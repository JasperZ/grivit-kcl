schema KcOpenIdGroupMembershipProtocolMapperWrapper:
    _claimName: str
    _clientScopeId: str
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectNamespace: str
    _realmId: str

    managedResource: ManagedResource {
        apiVersion = "openidgroup.keycloak.crossplane.io/v1alpha1"
        kind = "GroupMembershipProtocolMapper"
        metadata.name = "${_name}-${_clientScopeId}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-${_clientScopeId}"
        }
        metadata.labels = {
            "keycloak-instance" = _instanceName
            "keycloak-instance-owner-roject" = _instanceOwnerProjectName
            "keycloak-realm-id" = _realmId
            "project" = _projectNamespace
        }
        spec.forProvider.addToAccessToken = True
        spec.forProvider.addToIdToken = True
        spec.forProvider.addToUserinfo = True
        spec.forProvider.claimName = _claimName
        spec.forProvider.clientScopeId = _clientScopeId
        spec.forProvider.fullPath = False
        spec.forProvider.name = "groups"
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectNamespace, _instanceOwnerProjectName, _instanceName, _realmId)
    }
    usages: [Usage] = []

