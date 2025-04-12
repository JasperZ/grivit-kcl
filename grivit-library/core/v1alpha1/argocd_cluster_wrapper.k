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

    _argoCdInstanceOverride: ArgoCdInstance {
        domain = _argoCdInstance.domain
        name = _argoCdInstance.name
        ownerProjectName = _argoCdInstance.ownerProjectName
        projectName = "instance"
    }

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
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstanceOverride)
    }
    usages: [Usage] = []

