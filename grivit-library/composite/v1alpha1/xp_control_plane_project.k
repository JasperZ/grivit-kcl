import core.v1alpha1 as core
import composite.v1alpha1 as composite

schema XpControlPlaneProject:
    _k8sClusterName: str
    _projectNamespace: str

    awsProviderConfigSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-aws-provider"
        _secretName = "${_projectNamespace}-aws-provider"
        _stringData = None
        _namespace = _projectNamespace
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "ctrl-${_projectNamespace}-aws-provider"
                    namespace = "crossplane"
                }
            }
        ]
        managedResource.spec.providerConfigRef.name = "ctrl-${_projectNamespace}-k8s"
    }
    awsProviderConfig: core.AwsProviderConfigWrapper {
        _name = "${_projectNamespace}-aws"
        _credentialsSecretName = awsProviderConfigSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = _projectNamespace
    }
    helmProviderConfigSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-helm-provider"
        _secretName = "${_projectNamespace}-helm-provider"
        _stringData = None
        _namespace = _projectNamespace
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "ctrl-${_projectNamespace}-helm-provider"
                    namespace = "crossplane"
                }
            }
        ]
        managedResource.spec.providerConfigRef.name = "ctrl-${_projectNamespace}-k8s"
    }
    helmProviderConfig: core.HelmProviderConfigWrapper {
        _name = "${_projectNamespace}-${_k8sClusterName}-helm"
        _credentialsSecretName = helmProviderConfigSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = _projectNamespace
    }
    k8sProviderConfigSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-k8s-provider"
        _secretName = "${_projectNamespace}-k8s-provider"
        _stringData = None
        _namespace = _projectNamespace
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "ctrl-${_projectNamespace}-k8s-provider"
                    namespace = "crossplane"
                }
            }
        ]
        managedResource.spec.providerConfigRef.name = "ctrl-${_projectNamespace}-k8s"
    }
    k8sProviderConfig: core.K8sProviderConfigWrapper {
        _name = "${_projectNamespace}-${_k8sClusterName}-k8s"
        _credentialsSecretName = k8sProviderConfigSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = _projectNamespace
    }
    osProviderConfigSecret: core.K8sObjectSecretWrapper {
        _clusterName = _k8sClusterName
        _name = "${_projectNamespace}-os-provider"
        _secretName = "${_projectNamespace}-os-provider"
        _stringData = None
        _namespace = _projectNamespace
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "ctrl-${_projectNamespace}-os-provider"
                    namespace = "crossplane"
                }
            }
        ]
        managedResource.spec.providerConfigRef.name = "ctrl-${_projectNamespace}-k8s"
    }
    osProviderConfig: core.OsProviderConfigWrapper {
        _name = "${_projectNamespace}-os"
        _credentialsSecretName = k8sProviderConfigSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = "crossplane"
    }
    # k8sAppBundleCrds: composite.K8sAppBundleCrds {}
    managedResources: [core.ManagedResource | core.AwsProviderConfig | core.HelmProviderConfig | core.K8sProviderConfig | core.OsProviderConfig] = sum([[
        awsProviderConfigSecret.managedResource
        awsProviderConfig.managedResource
        helmProviderConfigSecret.managedResource
        helmProviderConfig.managedResource
        k8sProviderConfigSecret.managedResource
        k8sProviderConfig.managedResource
        osProviderConfigSecret.managedResource
        osProviderConfig.managedResource
    ]], [
        # k8sAppBundleCrds.managedResources
    ])

    usages: [core.Usage] = sum([
        awsProviderConfig.usages
        helmProviderConfig.usages
        k8sProviderConfig.usages
        osProviderConfig.usages
        # k8sAppBundleCrds.usages
    ], [])

