schema K8sObjectSecretWrapper:
    _clusterName: str
    _name: str
    _namespace: str
    _projectNamespace: str
    _secretName: str
    _stringData: {str:str}
    _uses: [ManagedResource] = []

    _targetK8sProviderConfigName: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "v1"
            kind = "Secret"
            metadata.name = _secretName
            metadata.namespace = _namespace
            type = "Opaque"
            stringData = _stringData
        }
        spec.providerConfigRef.name = "${_projectNamespace}-${_clusterName}-k8s"
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

