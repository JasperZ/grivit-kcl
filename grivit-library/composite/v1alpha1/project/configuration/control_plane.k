import core.v1alpha1 as core
import core.v1alpha1.aws_utils as awsUtils
import core.v1alpha1.helm_utils as helmUtils
import core.v1alpha1.k8s_utils as k8sUtils
import core.v1alpha1.os_utils as osUtils

import ...app.k8s as apps

schema ControlPlane:
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
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "bootstrap-aws-provider"
                    namespace = "bootstrap"
                }
                toFieldPath = "data.value"
            }
        ]
        managedResource.spec.providerConfigRef.name = "bootstrap-k8s"
    }
    awsProviderConfig: core.AwsProviderConfigWrapper {
        _credentialsSecretName = awsProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = awsProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
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
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "bootstrap-helm-provider"
                    namespace = "bootstrap"
                }
                toFieldPath = "data.value"
            }
        ]
        managedResource.spec.providerConfigRef.name = "bootstrap-k8s"
    }
    helmProviderConfig: core.HelmProviderConfigWrapper {
        _clusterName = _k8sClusterName
        _credentialsSecretName = helmProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = helmProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
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
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "bootstrap-k8s-provider"
                    namespace = "bootstrap"
                }
                toFieldPath = "data.value"
            }
        ]
        managedResource.spec.providerConfigRef.name = "bootstrap-k8s"
    }
    k8sProviderConfig: core.K8sProviderConfigWrapper {
        _clusterName = _k8sClusterName
        _credentialsSecretName = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
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
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "bootstrap-os-provider"
                    namespace = "bootstrap"
                }
                toFieldPath = "data.value"
            }
        ]
        managedResource.spec.providerConfigRef.name = "bootstrap-k8s"
    }
    osProviderConfig: core.OsProviderConfigWrapper {
        _credentialsSecretName = osProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = osProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectNamespace = _projectNamespace
        _uses = [
            osProviderConfigCredentialsSecret.managedResource
        ]
    }
    k8sAppPrometheusOperatorCrds: apps.PrometheusOperatorCrds {
        _clusterName = _k8sClusterName
        _name = "${_clusterName}-crd-prom"
        _projectNamespace = _projectNamespace
    }
    k8sAppOpenStackCinderCsi: apps.OpenStackCinderCsi {
        _clusterName = _k8sClusterName
        _fluxHelmReleaseDependencies = [k8sAppPrometheusOperatorCrds.helmRelease]
        _name = "${_projectNamespace}-${_k8sClusterName}-ia-ocsi"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppOpenStackExternalDns: apps.OpenStackExternalDns {
        _clusterName = _k8sClusterName
        _domainFilters = [_domain]
        _fluxHelmReleaseDependencies = [k8sAppPrometheusOperatorCrds.helmRelease]
        _name = "${_projectNamespace}-${_k8sClusterName}-ia-oexdns"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppCertManager: apps.CertManager {
        _clusterName = _k8sClusterName
        _email: _contactEmail
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _name = "${_projectNamespace}-${_k8sClusterName}-certmanager"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppIngressNginx: apps.IngressNginx {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-${_k8sClusterName}-ingress"
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _projectNamespace = _projectNamespace
    }
    k8sAppMetricsServer: apps.MetricsServer {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-${_k8sClusterName}-metrics"
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _projectNamespace = _projectNamespace
    }
    k8sAppSnapshotController: apps.SnapshotController {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-${_k8sClusterName}-sc"
        _projectNamespace = _projectNamespace
    }
    # ToDo: Velero
    k8sAppVerticalPodAutoscaler: apps.VerticalPodAutoscaler {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-${_k8sClusterName}-vpa"
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _projectNamespace = _projectNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppPrometheusOperatorCrds.helmRelease
        k8sAppOpenStackCinderCsi.helmRelease
        k8sAppOpenStackExternalDns.helmRelease
        k8sAppCertManager.helmRelease
        k8sAppIngressNginx.helmRelease
        k8sAppMetricsServer.helmRelease
        k8sAppVerticalPodAutoscaler.helmRelease
    ]
    managedResources: [core.ManagedResource | core.AwsProviderConfig | core.HelmProviderConfig | core.K8sProviderConfig | core.OsProviderConfig] = sum([
        k8sAppPrometheusOperatorCrds.managedResources
        k8sAppOpenStackCinderCsi.managedResources
        k8sAppOpenStackExternalDns.managedResources
        k8sAppCertManager.managedResources
        k8sAppIngressNginx.managedResources
        k8sAppMetricsServer.managedResources
        k8sAppSnapshotController.managedResources
        k8sAppVerticalPodAutoscaler.managedResources
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
        awsProviderConfigCredentialsSecret.usages
        awsProviderConfig.usages
        helmProviderConfigCredentialsSecret.usages
        helmProviderConfig.usages
        k8sProviderConfigCredentialsSecret.usages
        k8sProviderConfig.usages
        osProviderConfigCredentialsSecret.usages
        osProviderConfig.usages
        k8sAppPrometheusOperatorCrds.usages
        k8sAppOpenStackCinderCsi.usages
        k8sAppOpenStackExternalDns.usages
        k8sAppCertManager.usages
        k8sAppIngressNginx.usages
        k8sAppMetricsServer.usages
        k8sAppSnapshotController.usages
        k8sAppVerticalPodAutoscaler.usages
    ], [])

