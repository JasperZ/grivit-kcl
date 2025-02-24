schema KcUserGroupsWrapper:
    _groupIds: [str]
    _instanceName: str
    _projectNamespace: str
    _realmId: str
    _userId: str

    _resourceName: str = "${_projectNamespace}-${_instanceName}-${_realmId}-${_userId}-groups"

    managedResource: ManagedResource {
        apiVersion = "user.keycloak.crossplane.io/v1alpha1"
        kind = "Groups"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider.exhaustive = True
        spec.forProvider.groupIds = _groupIds
        spec.forProvider.realmId = _realmId
        spec.forProvider.userId = _userId
        spec.providerConfigRef.name = "${_projectNamespace}-${_instanceName}-${_realmId}-kc"
    }
    usages: [Usage] = []

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _atProviderId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _atProviderId
    }

