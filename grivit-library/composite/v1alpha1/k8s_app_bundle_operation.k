import core.v1alpha1 as core
import .app.k8s as apps

schema K8sAppBundleOperation:
    _argoCdDomain: str
    _clusterName: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _kcInstanceName: str
    _kcRealmId: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str
    # _headlampDomain: str
    
    k8sAppsOperationArgoCd: apps.ArgoCdAppK8s {
        _kubernetesClusterName = _clusterName
        _argoCdDomain = _argoCdDomain
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _keycloakInstanceName = _kcInstanceName
        _keycloakRealmId = _kcRealmId
        _name = "${_name}-argocd"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    # k8sAppsOperationHeadlamp: K8sAppOperationsHeadlamp {
    #     _name = "${_name}-headlamp"
    #     _domain = _headlampDomain
    #     _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
    #     _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    #     _targetK8sProviderConfig = _targetK8sProviderConfig
    #     _projectNamespace = _projectNamespace
    # }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsOperationArgoCd.helmRelease
        # k8sAppsOperationHeadlamp.helmRelease
    ]

    managedResources: [core.ManagedResource] = sum([
        k8sAppsOperationArgoCd.managedResources
        # k8sAppsOperationHeadlamp.managedResources
    ], [])

    usages: [core.Usage] = sum([
        k8sAppsOperationArgoCd.usages
        # k8sAppsOperationHeadlamp.usages
    ], [])

