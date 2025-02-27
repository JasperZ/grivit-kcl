import core.v1alpha1 as core
import core.v1alpha1.k8s_utils as k8sUtils

schema XpControlPlaneProject:
    _contactEmail: str
    _domain: str
    _k8sClusterName: str
    _observedComposedResources: any
    _projectNamespace: str

    k8sProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = k8sUtils.k8sProviderConfigSecretName(_projectNamespace, _k8sClusterName)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = k8sUtils.k8sProviderConfigSecretName(_projectNamespace, _k8sClusterName)
        _stringData = {}
        managedResource.spec.references = {
            patchesFrom = {
                apiVersion = "v1"
                fieldPath = "data.value"
                kind = "Secret"
                name = "bootstrap-k8s-ctrl"
                namespace = "bootstrap"
            }
            toFieldPath = "data.value"
        }
    }
    k8sProviderConfig: core.K8sProviderConfigWrapper {
        _clusterName = _k8sClusterName
        _credentialsSecretName = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.name
        _credentialsSecretNamespace = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.namespace
        _projectNamespace = _projectNamespace
    }
    k8sAppBundleCrds: K8sAppBundleCrds {
        _clusterName = _k8sClusterName
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsCSIDriver: K8sAppInfrastructureOsCsiDriver {
        _clusterName = _k8sClusterName
        _fluxHelmReleaseDependencies = k8sAppBundleCrds.fluxHelmReleases
        _name = "${_projectNamespace}-${_k8sClusterName}-ia-ocsi"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsExternalDNS: K8sAppInfrastructureOsExternalDNS {
        _clusterName = _k8sClusterName
        _domainFilters = [_domain]
        _fluxHelmReleaseDependencies = k8sAppBundleCrds.fluxHelmReleases
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
    ], [
        k8sProviderConfigCredentialsSecret.managedResource
        k8sProviderConfig.managedResource
    ])

    usages: [core.Usage] = sum([
        k8sAppBundleCrds.usages
        k8sAppsInfrastructureOsCSIDriver.usages
        k8sAppsInfrastructureOsExternalDNS.usages
        k8sAppsPlatformBundle.usages
    ], [
        k8sProviderConfigCredentialsSecret.usages
        k8sProviderConfig.usages
    ])

