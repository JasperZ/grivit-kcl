import core.v1alpha1 as core
import .app.k8s as apps

schema K8sAppBundleOsInfrastructure:
    _clusterName: str
    _clusterSubnetId: str
    _domainFilters: [str]
    _externalNetworkId: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    appCilium: apps.Cilium {
        _clusterName = _clusterName
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-cilium"
        _projectNamespace = _projectNamespace
    }
    appOpenStackCloudControllerManager: apps.OpenStackCloudControllerManager {
        _clusterName = _clusterName
        _clusterSubnetId = _clusterSubnetId
        _externalNetworkId = _externalNetworkId
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-occm"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    appOpenStackCinderCsi: apps.OpenStackCinderCsi {
        _clusterName = _clusterName
        _name = "${_name}-ocsi"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    appOpenStackExternalDns: apps.OpenStackExternalDns {
        _clusterName = _clusterName
        _domainFilters = _domainFilters
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-oexdns"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    appClusterAutoscaler: apps.ClusterAutoscaler {
        _clusterName = _clusterName
        _name = "${_name}-ca"
        _projectNamespace = _projectNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        appCilium.helmRelease
        appOpenStackCloudControllerManager.helmRelease
        appOpenStackCinderCsi.helmRelease
        appOpenStackExternalDns.helmRelease
    ]

    managedResources: [core.ManagedResource] = appCilium.managedResources + appOpenStackCloudControllerManager.managedResources + appOpenStackCinderCsi.managedResources + appOpenStackExternalDns.managedResources + appClusterAutoscaler.managedResources
    usages: [core.Usage] = appCilium.usages + appOpenStackCloudControllerManager.usages + appOpenStackCinderCsi.usages + appOpenStackExternalDns.usages + appClusterAutoscaler.usages

