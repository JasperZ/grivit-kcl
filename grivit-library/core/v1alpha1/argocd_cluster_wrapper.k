schema ArgoCdClusterWrapper:
    _argoCdInstance: ArgoCdInstance
    _argoCdClusterKubeconfigSecretKey: str
    _argoCdClusterKubeconfigSecretName: str
    _argoCdClusterKubeconfigSecretNamespace: str
    _argoCdClusterName: str
    _argoCdClusterNamespaces: [str] = []
    _argoCdClusterProject?: str
    _projectName: str
    _resourceName: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "cluster.argocd.crossplane.io/v1alpha1"
        kind = "Cluster"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            config = {
                kubeconfigSecretRef = {
                    key = _argoCdClusterKubeconfigSecretKey
                    name = _argoCdClusterKubeconfigSecretName
                    namespace = _argoCdClusterKubeconfigSecretNamespace
                }
            }
            name = _argoCdClusterName
            namespaces = _argoCdClusterNamespaces
            if _argoCdClusterProject:
                project = _argoCdClusterProject
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstance)
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
