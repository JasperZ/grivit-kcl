schema K8sProviderConfigWrapper:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _uses: [ManagedResource] = []

    managedResource: K8sProviderConfig {
        _name = _name
        _credentialsSecretName = _credentialsSecretName
        _credentialsSecretNamespace = _credentialsSecretNamespace
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

