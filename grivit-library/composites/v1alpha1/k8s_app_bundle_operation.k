import core.v1alpha1 as core

schema K8sAppBundleOperation:
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str
    _argoCdDomain: str
    _headlampDomain: str

    k8sAppsOperationArgoCd: K8sAppOperationsArgoCd {
        _name = "${_name}-argocd"
        _domain = _argoCdDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfigWrapper = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsOperationHeadlamp: K8sAppOperationsHeadlamp {
        _name = "${_name}-headlamp"
        _domain = _headlampDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsOperationArgoCd.helmRelease
        k8sAppsOperationHeadlamp.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppsOperationArgoCd.managedResources + k8sAppsOperationHeadlamp.managedResources
    usages: [core.Usage] = k8sAppsOperationArgoCd.usages + k8sAppsOperationHeadlamp.usages

