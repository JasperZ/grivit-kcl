import api.cp.core.v1 as cpCore

schema ProviderConfigWrapper:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _uses: [cpCore.ManagedResource] = []

    managedResource: ProviderConfig {
        _name = _name
        _credentialsSecretName = _credentialsSecretName
        _credentialsSecretNamespace = _credentialsSecretNamespace
    }
    usages: [cpCore.Usage] = [cpCore.Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

