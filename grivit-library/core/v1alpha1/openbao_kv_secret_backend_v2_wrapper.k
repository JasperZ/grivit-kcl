schema OpenBaoKvSecretBackendV2Wrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "kv.vault.upbound.io/v1alpha1"
        kind = "SecretBackendV2"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.mount = "${_projectName}/kv}"
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = []

