schema TfProviderConfigWrapper:
    _name: str
    _configuration: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _uses: [ManagedResource] = []

    managedResource: TfProviderConfig {
        _name = _name
        _configuration = _configuration
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

