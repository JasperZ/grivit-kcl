import core.v1alpha1 as core

schema K8sAppBundleOsInfrastructure:
    _clusterName: str
    _clusterSubnetId: str
    _controlPlaneHelmProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _domainFilters: [str]
    _externalNetworkId: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _targetOsProviderConfigName: str
    _projectNamespace: str

    k8sAppsInfrastructureCilium: K8sAppInfrastructureCilium {
        _clusterName = _clusterName
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-cilium"
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsCloudControllerManager: K8sAppInfrastructureOsCloudControllerManager {
        _clusterName = _clusterName
        _clusterSubnetId = _clusterSubnetId
        _externalNetworkId = _externalNetworkId
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-occm"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsCSIDriver: K8sAppInfrastructureOsCsiDriver {
        _clusterName = _clusterName
        _name = "${_name}-ocsi"
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsExternalDNS: K8sAppInfrastructureOsExternalDNS {
        _clusterName = _clusterName
        _domainFilters = _domainFilters
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _name = "${_name}-oexdns"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureClusterAutoscaler: K8sAppInfrastructureClusterAutoscaler {
        _clusterName = _clusterName
        _name = "${_name}-ca"
        _projectNamespace = _projectNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsInfrastructureCilium.helmRelease
        k8sAppsInfrastructureOsCloudControllerManager.helmRelease
        k8sAppsInfrastructureOsCSIDriver.helmRelease
        k8sAppsInfrastructureOsExternalDNS.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppsInfrastructureCilium.managedResources + k8sAppsInfrastructureOsCloudControllerManager.managedResources + k8sAppsInfrastructureOsCSIDriver.managedResources + k8sAppsInfrastructureOsExternalDNS.managedResources + k8sAppsInfrastructureClusterAutoscaler.managedResources
    usages: [core.Usage] = k8sAppsInfrastructureCilium.usages + k8sAppsInfrastructureOsCloudControllerManager.usages + k8sAppsInfrastructureOsCSIDriver.usages + k8sAppsInfrastructureOsExternalDNS.usages + k8sAppsInfrastructureClusterAutoscaler.usages

