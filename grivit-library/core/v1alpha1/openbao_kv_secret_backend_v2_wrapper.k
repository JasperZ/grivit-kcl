schema OpenBaoKvSecretBackendV2Wrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str
    _projectNamespace: str
    _uses: [ManagedResource]

    managedResource: ManagedResource {
        apiVersion = "kv.vault.upbound.io/v1alpha1"
        kind = "SecretBackendV2"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.mount = "${_projectName}/kvv2"
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

