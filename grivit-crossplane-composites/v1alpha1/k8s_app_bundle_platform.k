import api.cp.core.v1 as cpCore
import api.cp.k8s.app.v1 as cpK8sApp
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppBundlePlatform:
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _name: str
    _observedCompositeResource: any
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    k8sAppsPlatformCertManager: cpK8sApp.PlatformCertManager {
        _name = "${_name}-certmanager"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _observedCompositeResource = _observedCompositeResource
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformIngressNginx: cpK8sApp.PlatformIngressNginx {
        _name = "${_name}-ingress"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformMetricsServer: cpK8sApp.PlatformMetricsServer {
        _name = "${_name}-metrics"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformSnapshotController: cpK8sApp.PlatformSnapshotController {
        _name = "${_name}-sc"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    # ToDo: Velero
    k8sAppsPlatformVerticalPodAutoscaler: cpK8sApp.PlatformVerticalPodAutoscaler {
        _name = "${_name}-vpa"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [cpK8sFlux.HelmReleaseWrapper] = [
        k8sAppsPlatformIngressNginx.helmRelease
        k8sAppsPlatformMetricsServer.helmRelease
        k8sAppsPlatformVerticalPodAutoscaler.helmRelease
    ]

    managedResources: [cpCore.ManagedResource] = k8sAppsPlatformCertManager.managedResources + k8sAppsPlatformIngressNginx.managedResources + k8sAppsPlatformMetricsServer.managedResources + k8sAppsPlatformSnapshotController.managedResources + k8sAppsPlatformVerticalPodAutoscaler.managedResources
    usages: [cpCore.Usage] = k8sAppsPlatformCertManager.usages + k8sAppsPlatformIngressNginx.usages + k8sAppsPlatformMetricsServer.usages + k8sAppsPlatformSnapshotController.usages + k8sAppsPlatformVerticalPodAutoscaler.usages

