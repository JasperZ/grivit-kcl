schema OpenBaoAppRoleAuthBackendLoginWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _loginRoleId: str
    _loginSecretIdResourceName: str
    _name: str
    _projectName: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "approle.vault.upbound.io/v1alpha1"
        kind = "AuthBackendLogin"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.backend = "${_projectName}/approle"
        spec.forProvider.roleId = _loginRoleId
        spec.forProvider.secretIdSecretRef.key = "secret_id"
        spec.forProvider.secretIdSecretRef.name = _loginSecretIdResourceName
        spec.forProvider.secretIdSecretRef.namespace = _projectNamespace
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = []
