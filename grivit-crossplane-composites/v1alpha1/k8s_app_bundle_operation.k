import xresources.v1alpha1 as res

schema K8sAppBundleOperation:
    _name: str
    _fluxHelmReleaseDependencies?: [res.K8sFluxHelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _tenantNamespace: str
    _argoCdDomain: str
    _headlampDomain: str

    k8sAppsOperationArgoCd: K8sAppOperationArgoCd {
        _name = "${_name}-argocd"
        _domain = _argoCdDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsOperationHeadlamp: K8sAppOperationHeadlamp {
        _name = "${_name}-headlamp"
        _domain = _headlampDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [res.K8sFluxHelmReleaseWrapper] = [
        k8sAppsOperationArgoCd.helmRelease
        k8sAppsOperationHeadlamp.helmRelease
    ]

    managedResources: [res.ManagedResource] = k8sAppsOperationArgoCd.managedResources + k8sAppsOperationHeadlamp.managedResources
    usages: [res.Usage] = k8sAppsOperationArgoCd.usages + k8sAppsOperationHeadlamp.usages

