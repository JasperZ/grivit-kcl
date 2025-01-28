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
    _observedCompositeResource: any
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _targetOsProviderConfigName: str
    _tenantNamespace: str

    k8sAppsInfrastructureCilium: K8sAppInfrastructureCilium {
        _name = "${_name}-cilium"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureOsCloudControllerManager: K8sAppInfrastructureOsCloudControllerManager {
        _name = "${_name}-occm"
        _clusterName = _clusterName
        _clusterSubnetId = _clusterSubnetId
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _externalNetworkId = _externalNetworkId
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureOsCSIDriver: K8sAppInfrastructureOsCsiDriver {
        _name = "${_name}-ocsi"
        _clusterName = _clusterName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _observedCompositeResource = _observedCompositeResource
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureOsExternalDNS: K8sAppInfrastructureOsExternalDNS {
        _name = "${_name}-oexdns"
        _clusterName = _clusterName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _domainFilters = _domainFilters
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _observedCompositeResource = _observedCompositeResource
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureClusterAutoscaler: K8sAppInfrastructureClusterAutoscaler {
        _name = "${_name}-ca"
        _clusterName = _clusterName
        _clusterKubeconfigSecretName = _targetK8sProviderConfig.managedResource.spec.credentials.secretRef.name
        _controlPlaneHelmProviderConfigName = _controlPlaneHelmProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsInfrastructureCilium.helmRelease
        k8sAppsInfrastructureOsCloudControllerManager.helmRelease
        k8sAppsInfrastructureOsCSIDriver.helmRelease
        k8sAppsInfrastructureOsExternalDNS.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppsInfrastructureCilium.managedResources + k8sAppsInfrastructureOsCloudControllerManager.managedResources + k8sAppsInfrastructureOsCSIDriver.managedResources + k8sAppsInfrastructureOsExternalDNS.managedResources + k8sAppsInfrastructureClusterAutoscaler.managedResources
    usages: [core.Usage] = k8sAppsInfrastructureCilium.usages + k8sAppsInfrastructureOsCloudControllerManager.usages + k8sAppsInfrastructureOsCSIDriver.usages + k8sAppsInfrastructureOsExternalDNS.usages + k8sAppsInfrastructureClusterAutoscaler.usages

