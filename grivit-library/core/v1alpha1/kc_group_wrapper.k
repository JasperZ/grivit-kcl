schema KcGroupWrapper:
    _groupName: str
    _instanceName: str
    _instanceOwnerProjectName: str
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
        metadata.labels = {
            "keycloak-instance" = _instanceName
            "keycloak-instance-owner-roject" = _instanceOwnerProjectName
            "keycloak-realm-id" = _realmId
            "project" = _projectNamespace
        }
        spec.forProvider.name = _groupName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-${_realmId}"
    }
    usages: [Usage] = []

