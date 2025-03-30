import core.v1alpha1 as core
import .app.k8s as apps

schema K8sAppBundlePlatform:
    _clusterName: str
    _email: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    k8sAppsPlatformCertManager: apps.CertManager {
        _clusterName = _clusterName
        _email: _email
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-certmanager"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformIngressNginx: apps.IngressNginx {
        _clusterName = _clusterName
        _name = "${_name}-ingress"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformMetricsServer: apps.MetricsServer {
        _clusterName = _clusterName
        _name = "${_name}-metrics"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformSnapshotController: apps.SnapshotController {
        _clusterName = _clusterName
        _name = "${_name}-sc"
        _projectNamespace = _projectNamespace
    }
    # ToDo: Velero
    k8sAppsPlatformVerticalPodAutoscaler: apps.VerticalPodAutoscaler {
        _clusterName = _clusterName
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

