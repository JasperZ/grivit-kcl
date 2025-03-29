schema OpenBaoAppRoleAuthBackendRoleSecretIdWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str
    _projectNamespace: str
    _roleName: str

    managedResource: ManagedResource {
        apiVersion = "approle.vault.upbound.io/v1alpha1"
        kind = "AuthBackendRoleSecretID"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.backend = "${_projectName}/approle"
        spec.forProvider.roleName = _roleName
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
        spec.writeConnectionSecretToRef.name = _name
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
    }
    usages: [Usage] = []

    getSecretId: (any) -> str = lambda observedComposedResources: any -> str {
        _secretId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _secretId = str(base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails["attribute.secret_id"]))

        _secretId
    }
