schema KcUserGroupsWrapper:
    _groupIds: [str]
    _instanceName: str
    _instanceOwnerProjectName: str
    _projectNamespace: str
    _realmId: str
    _userId: str
    _uses: [ManagedResource] = []

    _resourceName: str = "-${_realmId}-${_userId}-groups"

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
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-${_realmId}"
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_resourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_resourceName}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

