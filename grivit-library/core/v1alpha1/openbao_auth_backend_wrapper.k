schema OpenBaoAuthBackendWrapper:
    _backendDescription: str
    _backendType: "approle"
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "auth.vault.upbound.io/v1alpha1"
        kind = "Backend"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.description = _backendDescription
        spec.forProvider.path = "${_projectName}/${_backendType}"
        spec.forProvider.type = _backendType
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = []

