import core.v1alpha1 as core

schema K8sAppBundlePlatform:
    _clusterName: str
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _email: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _projectNamespace: str

    k8sAppsPlatformCertManager: K8sAppPlatformCertManager {
        _clusterName = _clusterName
        _email: _email
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-certmanager"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformIngressNginx: K8sAppPlatformIngressNginx {
        _clusterName = _clusterName
        _name = "${_name}-ingress"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformMetricsServer: K8sAppPlatformMetricsServer {
        _clusterName = _clusterName
        _name = "${_name}-metrics"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformSnapshotController: K8sAppPlatformSnapshotController {
        _clusterName = _clusterName
        _name = "${_name}-sc"
        _projectNamespace = _projectNamespace
    }
    # ToDo: Velero
    k8sAppsPlatformVerticalPodAutoscaler: K8sAppPlatformVerticalPodAutoscaler {
        _name = "${_name}-vpa"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsPlatformIngressNginx.helmRelease
        k8sAppsPlatformMetricsServer.helmRelease
        k8sAppsPlatformVerticalPodAutoscaler.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppsPlatformCertManager.managedResources + k8sAppsPlatformIngressNginx.managedResources + k8sAppsPlatformMetricsServer.managedResources + k8sAppsPlatformSnapshotController.managedResources + k8sAppsPlatformVerticalPodAutoscaler.managedResources
    usages: [core.Usage] = k8sAppsPlatformCertManager.usages + k8sAppsPlatformIngressNginx.usages + k8sAppsPlatformMetricsServer.usages + k8sAppsPlatformSnapshotController.usages + k8sAppsPlatformVerticalPodAutoscaler.usages

