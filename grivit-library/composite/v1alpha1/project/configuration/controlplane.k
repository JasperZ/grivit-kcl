import crypto

import core.v1alpha1 as core
import core.v1alpha1.aws_utils as awsUtils
import core.v1alpha1.helm_utils as helmUtils
import core.v1alpha1.k8s_utils as k8sUtils
import core.v1alpha1.os_utils as osUtils

import ...app.k8s as apps

schema ControlPlaneProjectConfiguration:
    _claimName: str
    _claimNamespace: str
    _contactEmail: str
    _domain: str
    _k8sClusterName: str
    _observedComposedResources: any

    _managedResourcePrefix = "g-" + crypto.md5("${_claimNamespace}-${_claimName}") + "-"

    awsProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = awsUtils.awsProviderConfigSecretName(_claimNamespace)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = awsUtils.awsProviderConfigSecretName(_claimNamespace)
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
        _projectNamespace = _claimNamespace
        _uses = [
            awsProviderConfigCredentialsSecret.managedResource
        ]
    }
    helmProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = helmUtils.helmProviderConfigSecretName(_claimNamespace, _k8sClusterName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = helmUtils.helmProviderConfigSecretName(_claimNamespace, _k8sClusterName)
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
        _projectNamespace = _claimNamespace
        _uses = [
            helmProviderConfigCredentialsSecret.managedResource
        ]
    }
    httpProviderConfig: core.HttpProviderConfigWrapper {
        _projectNamespace = _claimNamespace
    }
    k8sProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = k8sUtils.k8sProviderConfigSecretName(_claimNamespace, _k8sClusterName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = k8sUtils.k8sProviderConfigSecretName(_claimNamespace, _k8sClusterName)
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
        _projectNamespace = _claimNamespace
        _uses = [
            k8sProviderConfigCredentialsSecret.managedResource
        ]
    }
    osProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = osUtils.osProviderConfigSecretName(_claimNamespace)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = osUtils.osProviderConfigSecretName(_claimNamespace)
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
        _projectNamespace = _claimNamespace
        _uses = [
            osProviderConfigCredentialsSecret.managedResource
        ]
    }
    k8sAppPrometheusOperatorCrds: apps.PrometheusOperatorCrdsAppK8s {
        _clusterName = _k8sClusterName
        _name = "${_managedResourcePrefix}prom-crds"
        _projectNamespace = _claimNamespace
    }
    k8sAppOpenStackCinderCsi: apps.OpenStackCinderCsiAppK8s {
        _clusterName = _k8sClusterName
        _fluxHelmReleaseDependencies = [k8sAppPrometheusOperatorCrds.helmRelease]
        _name = "${_managedResourcePrefix}cinder-csi"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    k8sAppOpenStackExternalDns: apps.OpenStackExternalDnsAppK8s {
        _clusterName = _k8sClusterName
        _domainFilters = [_domain]
        _fluxHelmReleaseDependencies = [k8sAppPrometheusOperatorCrds.helmRelease]
        _name = "${_managedResourcePrefix}external-dns"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    k8sAppCertManager: apps.CertManagerAppK8s {
        _clusterName = _k8sClusterName
        _email: _contactEmail
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _name = "${_managedResourcePrefix}certmgr"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    k8sAppIngressNginx: apps.IngressNginxAppK8s {
        _clusterName = _k8sClusterName
        _name = "${_managedResourcePrefix}ingress-nginx"
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _projectNamespace = _claimNamespace
    }
    k8sAppMetricsServer: apps.MetricsServerAppK8s {
        _clusterName = _k8sClusterName
        _name = "${_managedResourcePrefix}metrics"
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _projectNamespace = _claimNamespace
    }
    k8sAppSnapshotController: apps.SnapshotControllerAppK8s {
        _clusterName = _k8sClusterName
        _name = "${_managedResourcePrefix}snap-ctrl"
        _projectNamespace = _claimNamespace
    }
    # ToDo: Velero
    k8sAppVerticalPodAutoscaler: apps.VerticalPodAutoscalerAppK8s {
        _clusterName = _k8sClusterName
        _name = "${_managedResourcePrefix}vpa"
        _fluxHelmReleaseDependencies = [
            k8sAppOpenStackCinderCsi.helmRelease
            k8sAppOpenStackExternalDns.helmRelease
        ]
        _projectNamespace = _claimNamespace
    }
    k8sAppClusterApi: apps.ClusterApiAppK8s {
        _claimName = _claimName
        _claimNamespace = _claimNamespace
        _kubernetesClusterName = _k8sClusterName
        _fluxHelmReleaseDependencies = [
            k8sAppPrometheusOperatorCrds.helmRelease
            k8sAppCertManager.helmRelease
        ]
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppPrometheusOperatorCrds.helmRelease
        k8sAppOpenStackCinderCsi.helmRelease
        k8sAppOpenStackExternalDns.helmRelease
        k8sAppCertManager.helmRelease
        k8sAppIngressNginx.helmRelease
        k8sAppMetricsServer.helmRelease
        k8sAppVerticalPodAutoscaler.helmRelease
        k8sAppClusterApi.helmRelease
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
        k8sAppClusterApi.managedResources
    ], [
        awsProviderConfigCredentialsSecret.managedResource
        awsProviderConfig.managedResource
        helmProviderConfigCredentialsSecret.managedResource
        helmProviderConfig.managedResource
        httpProviderConfig.managedResource
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
        httpProviderConfig.usages
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
        k8sAppClusterApi.usages
    ], [])

