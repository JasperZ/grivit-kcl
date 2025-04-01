schema HttpProviderConfigWrapper:
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _resourceName: str = httpProviderConfigName(_projectNamespace)

    managedResource: HttpProviderConfig = {
        _name = _resourceName
        metadata.labels = {
            "project" = _projectNamespace
        }
        spec.credentials.source = "None"
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

