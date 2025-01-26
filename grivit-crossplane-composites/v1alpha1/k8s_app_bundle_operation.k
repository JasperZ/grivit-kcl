import api.cp.core.v1 as cpCore
import api.cp.k8s.app.v1 as cpK8sApp
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppBundleOperation:
    _name: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str
    _argoCdDomain: str
    _headlampDomain: str

    k8sAppsOperationArgoCd: cpK8sApp.OperationArgoCd {
        _name = "${_name}-argocd"
        _domain = _argoCdDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsOperationHeadlamp: cpK8sApp.OperationHeadlamp {
        _name = "${_name}-headlamp"
        _domain = _headlampDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [cpK8sFlux.HelmReleaseWrapper] = [
        k8sAppsOperationArgoCd.helmRelease
        k8sAppsOperationHeadlamp.helmRelease
    ]

    managedResources: [cpCore.ManagedResource] = k8sAppsOperationArgoCd.managedResources + k8sAppsOperationHeadlamp.managedResources
    usages: [cpCore.Usage] = k8sAppsOperationArgoCd.usages + k8sAppsOperationHeadlamp.usages

