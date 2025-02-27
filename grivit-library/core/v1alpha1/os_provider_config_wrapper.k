schema OsProviderConfigWrapper:
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _resourceName = osProviderConfigName(_projectNamespace)

    managedResource: OsProviderConfig {
        _name = _resourceName
        _credentialsSecretName = _credentialsSecretName
        _credentialsSecretNamespace = _credentialsSecretNamespace
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_resourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_resourceName}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

