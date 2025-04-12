import core.v1alpha1 as core
import ...project.infrastructure as infra

schema TenantProjectConfiguration:
    _claimNamespace: str
    _contactEmail: str
    _domain: str
    _observedComposedResources: any
    _projectName: str

    _k8sClusterName: str = "ctrl"

    awsProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = core.awsProviderConfigSecretName(_projectName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.awsProviderConfigSecretName(_projectName)
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
        _projectNamespace = _projectName
        _uses = [
            awsProviderConfigCredentialsSecret.managedResource
        ]
    }
    helmProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = core.helmProviderConfigSecretName(_projectName, _k8sClusterName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.helmProviderConfigSecretName(_projectName, _k8sClusterName)
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
        _projectNamespace = _projectName
        _uses = [
            helmProviderConfigCredentialsSecret.managedResource
        ]
    }
    httpProviderConfig: core.HttpProviderConfigWrapper {
        _projectNamespace = _projectName
    }
    k8sProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = core.k8sProviderConfigSecretName(_projectName, _k8sClusterName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.k8sProviderConfigSecretName(_projectName, _k8sClusterName)
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
        _projectNamespace = _projectName
        _uses = [
            k8sProviderConfigCredentialsSecret.managedResource
        ]
    }
    osProjectInfrastructure: infra.OsProjectInfrastructure {
        _domain = _domain
        _email = _contactEmail
        _name = "${_projectName}-openstack-project-infra"
        _observedComposedResources = _observedComposedResources
        _projectName = _projectName
        _projectNamespace = _claimNamespace
    }

    managedResources: [core.ManagedResource | core.AwsProviderConfig | core.HelmProviderConfig | core.K8sProviderConfig | core.OsProviderConfig] = sum([
        # k8sAppPrometheusOperatorCrds.managedResources
        # k8sAppOpenStackCinderCsi.managedResources
        # k8sAppOpenStackExternalDns.managedResources
        # k8sAppCertManager.managedResources
        # k8sAppIngressNginx.managedResources
        # k8sAppMetricsServer.managedResources
        # k8sAppSnapshotController.managedResources
        # k8sAppVerticalPodAutoscaler.managedResources
        osProjectInfrastructure.managedResources
    ], [
        awsProviderConfigCredentialsSecret.managedResource
        awsProviderConfig.managedResource
        helmProviderConfigCredentialsSecret.managedResource
        helmProviderConfig.managedResource
        httpProviderConfig.managedResource
        k8sProviderConfigCredentialsSecret.managedResource
        k8sProviderConfig.managedResource
    ])

    usages: [core.Usage] = sum([
        awsProviderConfigCredentialsSecret.usages
        awsProviderConfig.usages
        helmProviderConfigCredentialsSecret.usages
        helmProviderConfig.usages
        httpProviderConfig.usages
        k8sProviderConfigCredentialsSecret.usages
        k8sProviderConfig.usages
        osProjectInfrastructure.usages
    ], [])

