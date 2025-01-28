import core.v1alpha1 as core

schema K8sAppBundlePlatform:
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    k8sAppsPlatformCertManager: K8sAppPlatformCertManager {
        _name = "${_name}-certmanager"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _observedComposedResources = _observedComposedResources
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformIngressNginx: K8sAppPlatformIngressNginx {
        _name = "${_name}-ingress"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformMetricsServer: K8sAppPlatformMetricsServer {
        _name = "${_name}-metrics"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformSnapshotController: K8sAppPlatformSnapshotController {
        _name = "${_name}-sc"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    # ToDo: Velero
    k8sAppsPlatformVerticalPodAutoscaler: K8sAppPlatformVerticalPodAutoscaler {
        _name = "${_name}-vpa"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsPlatformIngressNginx.helmRelease
        k8sAppsPlatformMetricsServer.helmRelease
        k8sAppsPlatformVerticalPodAutoscaler.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppsPlatformCertManager.managedResources + k8sAppsPlatformIngressNginx.managedResources + k8sAppsPlatformMetricsServer.managedResources + k8sAppsPlatformSnapshotController.managedResources + k8sAppsPlatformVerticalPodAutoscaler.managedResources
    usages: [core.Usage] = k8sAppsPlatformCertManager.usages + k8sAppsPlatformIngressNginx.usages + k8sAppsPlatformMetricsServer.usages + k8sAppsPlatformSnapshotController.usages + k8sAppsPlatformVerticalPodAutoscaler.usages

