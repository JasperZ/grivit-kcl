schema K8sObjectConfigMapWrapper:
    _clusterName: str
    _configMapName: str
    _configMapNamespace: str
    _configMapData: {str:str}
    _name: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "v1"
            kind = "ConfigMap"
            metadata.name = _configMapName
            metadata.namespace = _configMapNamespace
            data = _configMapData
        }
        spec.providerConfigRef.name = k8sProviderConfigName(_projectNamespace, _clusterName)
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

    check:
        len(managedResource.metadata.name) < 64
        len(managedResource.spec.forProvider.manifest.metadata.name) < 64
