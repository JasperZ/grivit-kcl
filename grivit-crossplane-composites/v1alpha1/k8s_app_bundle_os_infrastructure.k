import api.cp.core.v1 as cpCore
import api.cp.k8s.app.v1 as cpK8sApp
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppBundleOsInfrastructure:
    _clusterName: str
    _clusterSubnetId: str
    _controlPlaneHelmProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _domainFilters: [str]
    _externalNetworkId: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _name: str
    _observedCompositeResource: any
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _targetOsProviderConfigName: str
    _tenantNamespace: str

    k8sAppsInfrastructureCilium: cpK8sApp.InfrastructureCilium {
        _name = "${_name}-cilium"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureOsCloudControllerManager: cpK8sApp.OsInfrastructureCloudControllerManager {
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
    k8sAppsInfrastructureOsCSIDriver: cpK8sApp.OsInfrastructureCSIDriver {
        _name = "${_name}-ocsi"
        _clusterName = _clusterName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _fluxHelmReleaseDependencies = _fluxHelmReleaseDependencies
        _observedCompositeResource = _observedCompositeResource
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureOsExternalDNS: cpK8sApp.OsInfrastructureExternalDNS {
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
    k8sAppsInfrastructureClusterAutoscaler: cpK8sApp.InfrastructureClusterAutoscaler {
        _name = "${_name}-ca"
        _clusterName = _clusterName
        _clusterKubeconfigSecretName = _targetK8sProviderConfig.managedResource.spec.credentials.secretRef.name
        _controlPlaneHelmProviderConfigName = _controlPlaneHelmProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [cpK8sFlux.HelmReleaseWrapper] = [
        k8sAppsInfrastructureCilium.helmRelease
        k8sAppsInfrastructureOsCloudControllerManager.helmRelease
        k8sAppsInfrastructureOsCSIDriver.helmRelease
        k8sAppsInfrastructureOsExternalDNS.helmRelease
    ]

    managedResources: [cpCore.ManagedResource] = k8sAppsInfrastructureCilium.managedResources + k8sAppsInfrastructureOsCloudControllerManager.managedResources + k8sAppsInfrastructureOsCSIDriver.managedResources + k8sAppsInfrastructureOsExternalDNS.managedResources + k8sAppsInfrastructureClusterAutoscaler.managedResources
    usages: [cpCore.Usage] = k8sAppsInfrastructureCilium.usages + k8sAppsInfrastructureOsCloudControllerManager.usages + k8sAppsInfrastructureOsCSIDriver.usages + k8sAppsInfrastructureOsExternalDNS.usages + k8sAppsInfrastructureClusterAutoscaler.usages

