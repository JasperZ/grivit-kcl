schema KcGroupArgoCdWrapper:
    _groupType: "admins" | "viewers"
    _instanceName: str
    _projectNamespace: str
    _realmId: str

    _groupName: str = "argocd-${_instanceName}-${_groupType}"
    _resourceName: str = "${_projectNamespace}-${_instanceName}-${_realmId}-argocd-${_groupType}-group"

    managedResource: ManagedResource {
        apiVersion = "group.keycloak.crossplane.io/v1alpha1"
        kind = "Group"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider.name = _groupName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = "${_projectNamespace}-${_instanceName}-${_realmId}-kc"
    }
    usages: [Usage] = []

