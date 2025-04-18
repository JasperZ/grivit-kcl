import core.v1alpha1 as core

schema ArgoCdIntegClusterK8s:
    _argoCdInstance: core.ArgoCdInstance
    _claimName: str
    _claimNamespace: str
    _composite: str
    _k8sCluster: core.K8sCluster

    _managedResourcePrefix: str = _composite + "-"
    _managedResourceSuffix: str = ""

    argoCdCluster: core.ArgoCdClusterWrapper {
        _argoCdInstance = _argoCdInstance
        _argoCdClusterKubeconfigSecretKey = "value"
        _argoCdClusterKubeconfigSecretName = core.k8sProviderConfigSecretName(_k8sCluster.projectName, _k8sCluster.name)
        _argoCdClusterKubeconfigSecretNamespace = _claimNamespace
        _argoCdClusterName = _k8sCluster.name
        _argoCdClusterProject = core.argoCdTenantProjectName(_argoCdInstance)
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}cluster${_managedResourceSuffix}"
    }

    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        argoCdCluster.managedResource
    ]
    usages: [core.Usage] = sum([
        argoCdCluster.usages
    ], [])
