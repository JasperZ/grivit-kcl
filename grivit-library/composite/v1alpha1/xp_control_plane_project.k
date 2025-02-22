import core.v1alpha1 as core

schema XpControlPlaneProject:
    _contactEmail: str
    _domain: str
    _k8sClusterName: str
    _observedComposedResources: any
    _projectNamespace: str

    k8sAppBundleCrds: K8sAppBundleCrds {
        _clusterName = _k8sClusterName
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsCSIDriver: K8sAppInfrastructureOsCsiDriver {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-${_k8sClusterName}-ia-ocsi"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsExternalDNS: K8sAppInfrastructureOsExternalDNS {
        _clusterName = _k8sClusterName
        _domainFilters = [_domain]
        _name = "${_projectNamespace}-${_k8sClusterName}-ia-oexdns"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformBundle: K8sAppBundlePlatform {
        _clusterName = _k8sClusterName
        _email = _contactEmail
        _fluxHelmReleaseDependencies = [
            k8sAppsInfrastructureOsCSIDriver.helmRelease
            k8sAppsInfrastructureOsExternalDNS.helmRelease
        ]
        _name = "${_projectNamespace}-${_k8sClusterName}-pa"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    managedResources: [core.ManagedResource | core.AwsProviderConfig | core.HelmProviderConfig | core.K8sProviderConfig | core.OsProviderConfig] = sum([
        k8sAppBundleCrds.managedResources
        k8sAppsInfrastructureOsCSIDriver.managedResources
        k8sAppsInfrastructureOsExternalDNS.managedResources
        k8sAppsPlatformBundle.managedResources
    ], [])

    usages: [core.Usage] = sum([
        k8sAppBundleCrds.usages
        k8sAppsInfrastructureOsCSIDriver.usages
        k8sAppsInfrastructureOsExternalDNS.usages
        k8sAppsPlatformBundle.usages
    ], [])

