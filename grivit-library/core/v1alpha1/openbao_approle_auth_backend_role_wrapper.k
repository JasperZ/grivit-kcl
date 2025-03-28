schema OpenBaoAppRoleAuthBackendRoleWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str
    _projectNamespace: str
    _roleName: str
    _roleTokenPolicies: [str] = []

    managedResource: ManagedResource {
        apiVersion = "approle.vault.upbound.io/v1alpha1"
        kind = "AuthBackendRole"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.backend = "${_projectName}/approle"
        spec.forProvider.roleName = _roleName
        spec.forProvider.tokenPolicies = _roleTokenPolicies
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = []

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _atProviderId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _atProviderId
    }
