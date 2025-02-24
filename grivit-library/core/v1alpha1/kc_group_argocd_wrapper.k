schema KcGroupArgoCdWrapper:
    _groupType: "admins" | "viewers"
    _instanceName: str
    _projectName: str
    _projectNamespace: str
    _realmId: str

    _groupName: str = "argocd-${_instanceName}-${_projectName}-${_groupType}"
    _resourceName: str = "${_projectNamespace}-${_instanceName}-${_realmId}-argocd-${_projectName}-${_groupType}-group"

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

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _atProviderId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _atProviderId
    }