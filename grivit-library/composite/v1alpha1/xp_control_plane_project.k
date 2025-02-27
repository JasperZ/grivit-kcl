import core.v1alpha1 as core
import core.v1alpha1.aws_utils as awsUtils
import core.v1alpha1.helm_utils as helmUtils
import core.v1alpha1.k8s_utils as k8sUtils
import core.v1alpha1.os_utils as osUtils

schema XpControlPlaneProject:
    _contactEmail: str
    _domain: str
    _k8sClusterName: str
    _observedComposedResources: any
    _projectNamespace: str

    awsProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = awsUtils.awsProviderConfigSecretName(_projectNamespace)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = awsUtils.awsProviderConfigSecretName(_projectNamespace)
        _stringData = {}
        managedResource.spec.references = {
            patchesFrom = {
                apiVersion = "v1"
                fieldPath = "data.value"
                kind = "Secret"
                name = "bootstrap-aws"
                namespace = "bootstrap"
            }
            toFieldPath = "data.value"
        }
    }
    awsProviderConfig: core.AwsProviderConfigWrapper {
        _credentialsSecretName = awsProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.name
        _credentialsSecretNamespace = awsProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.namespace
        _projectNamespace = _projectNamespace
        _uses = [
            awsProviderConfigCredentialsSecret.managedResource
        ]
    }
    helmProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = helmUtils.helmProviderConfigSecretName(_projectNamespace, _k8sClusterName)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = helmUtils.helmProviderConfigSecretName(_projectNamespace, _k8sClusterName)
        _stringData = {}
        managedResource.spec.references = {
            patchesFrom = {
                apiVersion = "v1"
                fieldPath = "data.value"
                kind = "Secret"
                name = "bootstrap-helm"
                namespace = "bootstrap"
            }
            toFieldPath = "data.value"
        }
    }
    helmProviderConfig: core.HelmProviderConfigWrapper {
        _clusterName = _k8sClusterName
        _credentialsSecretName = helmProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.name
        _credentialsSecretNamespace = helmProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.namespace
        _projectNamespace = _projectNamespace
        _uses = [
            helmProviderConfigCredentialsSecret.managedResource
        ]
    }
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
                name = "bootstrap-k8s"
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
        _uses = [
            k8sProviderConfigCredentialsSecret.managedResource
        ]
    }
    osProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = osUtils.osProviderConfigSecretName(_projectNamespace)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = osUtils.osProviderConfigSecretName(_projectNamespace)
        _stringData = {}
        managedResource.spec.references = {
            patchesFrom = {
                apiVersion = "v1"
                fieldPath = "data.value"
                kind = "Secret"
                name = "bootstrap-os"
                namespace = "bootstrap"
            }
            toFieldPath = "data.value"
        }
    }
    osProviderConfig: core.OsProviderConfigWrapper {
        _credentialsSecretName = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.name
        _credentialsSecretNamespace = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.metadata.namespace
        _projectNamespace = _projectNamespace
        _uses = [
            osProviderConfigCredentialsSecret.managedResource
        ]
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
        awsProviderConfigCredentialsSecret.managedResource
        awsProviderConfig.managedResource
        helmProviderConfigCredentialsSecret.managedResource
        helmProviderConfig.managedResource
        k8sProviderConfigCredentialsSecret.managedResource
        k8sProviderConfig.managedResource
        osProviderConfigCredentialsSecret.managedResource
        osProviderConfig.managedResource
    ])

    usages: [core.Usage] = sum([
        k8sAppBundleCrds.usages
        k8sAppsInfrastructureOsCSIDriver.usages
        k8sAppsInfrastructureOsExternalDNS.usages
        k8sAppsPlatformBundle.usages
    ], [
        awsProviderConfigCredentialsSecret.usages
        awsProviderConfig.usages
        helmProviderConfigCredentialsSecret.usages
        helmProviderConfig.usages
        k8sProviderConfigCredentialsSecret.usages
        k8sProviderConfig.usages
        osProviderConfigCredentialsSecret.usages
        osProviderConfig.usages
    ])

