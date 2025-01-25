import api.cp.core.v1 as cpCore

schema OpenIdGroupMembershipProtocolMapperWrapper:
    _controlPlaneKcProviderConfigName: str
    _claimName: str
    _clientScopeId: str
    _name: str
    _realmId: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "openidgroup.keycloak.crossplane.io/v1alpha1"
        kind = "GroupMembershipProtocolMapper"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.addToAccessToken = True
        spec.forProvider.addToIdToken = True
        spec.forProvider.addToUserinfo = True
        spec.forProvider.claimName = _claimName
        spec.forProvider.clientScopeId = _clientScopeId
        spec.forProvider.fullPath = False
        spec.forProvider.name = "groups"
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [cpCore.Usage] = []

