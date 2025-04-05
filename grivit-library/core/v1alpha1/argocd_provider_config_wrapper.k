schema ArgoCdProviderConfigWrapper:
    _argoCdInstance: ArgoCdInstance
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _projectName: str
    _uses: [ManagedResource] = []

    _resourceName: str = argoCdProviderConfigName(_projectName, _argoCdInstance)

    managedResource: ArgoCdProviderConfig {
        _name = _resourceName
        _credentialsSecretName = _credentialsSecretName
        _credentialsSecretNamespace = _credentialsSecretNamespace
        _argoCdDomain = _argoCdInstance.domain
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

