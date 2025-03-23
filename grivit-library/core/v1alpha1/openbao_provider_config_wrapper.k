schema OpenBaoProviderConfigWrapper:
    _credentialsSecretKey: str = "value"
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _openBaoDomain: str
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _openBaoProjectName: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _resourceName: str = openBaoProviderConfigName(_projectNamespace, _openBaoInstanceOwnerProjectName, _openBaoInstanceName, _openBaoProjectName)

    managedResource: OpenBaoProviderConfig {
        _name = _resourceName
        _credentialsSecretKey = _credentialsSecretKey
        _credentialsSecretName = _credentialsSecretName
        _credentialsSecretNamespace = _credentialsSecretNamespace
        _openBaoDomain = _openBaoDomain
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

