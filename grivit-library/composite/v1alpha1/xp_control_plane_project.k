import core.v1alpha1 as core

schema XpControlPlaneProject:
    _k8sClusterName: str
    _projectNamespace: str

    awsProviderConfig: core.AwsProviderConfigWrapper {
        _name = "${_projectNamespace}-aws"
        _credentialsSecretName = "ctrl-grivit-ctrl-crossplane-dev-aws-provider"
        _credentialsSecretNamespace = "crossplane"
    }
    helmProviderConfig: core.HelmProviderConfigWrapper {
        _name = "${_projectNamespace}-${_k8sClusterName}-helm"
        _credentialsSecretName = "ctrl-grivit-ctrl-crossplane-dev-helm-provider"
        _credentialsSecretNamespace = "crossplane"
    }
    k8sProviderConfig: core.K8sProviderConfigWrapper {
        _name = "${_projectNamespace}-${_k8sClusterName}-k8s"
        _credentialsSecretName = "ctrl-grivit-ctrl-crossplane-dev-k8s-provider"
        _credentialsSecretNamespace = "crossplane"
    }
    osProviderConfig: core.OsProviderConfigWrapper {
        _name = "${_projectNamespace}-os"
        _credentialsSecretName = "ctrl-grivit-ctrl-crossplane-dev-os-provider"
        _credentialsSecretNamespace = "crossplane"
    }
    managedResources: [core.ManagedResource | core.AwsProviderConfig | core.HelmProviderConfig | core.K8sProviderConfig | core.OsProviderConfig] = [
        awsProviderConfig.managedResource
        helmProviderConfig.managedResource
        k8sProviderConfig.managedResource
        osProviderConfig.managedResource
    ]
    usages: [core.Usage] = sum([
        awsProviderConfig.usages
        helmProviderConfig.usages
        k8sProviderConfig.usages
        osProviderConfig.usages
    ], [])

