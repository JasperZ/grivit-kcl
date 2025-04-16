schema K8sProviderConfigWrapper:
    _clusterName: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _resourceName: str = k8sProviderConfigName(_projectNamespace, _clusterName)

    managedResource: K8sProviderConfig {
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

    check:
        len(managedResource.metadata.name) < 64
