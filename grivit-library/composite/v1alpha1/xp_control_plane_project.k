import core.v1alpha1 as core

schema XpControlPlaneProject:
    _k8sClusterName: str
    _projectNamespace: str

    k8sAppBundleCrds: K8sAppBundleCrds {
        _clusterName = _k8sClusterName
        _projectNamespace = _projectNamespace
    }
    managedResources: [core.ManagedResource | core.AwsProviderConfig | core.HelmProviderConfig | core.K8sProviderConfig | core.OsProviderConfig] = sum([[]], [
        k8sAppBundleCrds.managedResources
    ])

    usages: [core.Usage] = sum([
        k8sAppBundleCrds.usages
    ], [])

