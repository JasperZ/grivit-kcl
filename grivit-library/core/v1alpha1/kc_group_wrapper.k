schema KcGroupWrapper:
    _groupName: str
    _instanceName: str
    _name: str
    _projectNamespace: str
    _realmId: str

    managedResource: ManagedResource {
        apiVersion = "group.keycloak.crossplane.io/v1alpha1"
        kind = "Group"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.name = _groupName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceName}-${_realmId}"
    }
    usages: [Usage] = []

