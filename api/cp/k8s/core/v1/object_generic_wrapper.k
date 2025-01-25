import api.cp.core.v1 as cpCore

schema ObjectGenericWrapper:
    _name: str
    _uses: [cpCore.ManagedResource] = []

    _targetK8sProviderConfigName: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec.providerConfigRef.name = _targetK8sProviderConfigName
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

