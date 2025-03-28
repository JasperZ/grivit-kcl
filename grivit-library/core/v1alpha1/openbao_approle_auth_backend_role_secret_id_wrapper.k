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
    }
    usages: [Usage] = []

