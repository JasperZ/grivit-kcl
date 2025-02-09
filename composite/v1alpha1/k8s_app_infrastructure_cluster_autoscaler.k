import core.v1alpha1 as core

schema K8sAppInfrastructureClusterAutoscaler:
    _name: str
    _clusterName: str
    _clusterKubeconfigSecretName: str
    _controlPlaneHelmProviderConfigName: str
    _tenantNamespace: str

    helmRelease: core.HelmReleaseWrapper {
        _name = _name
        _chartName = "cluster-autoscaler"
        _chartVersion = "9.40.0"
        _chartRepoUrl = "https://kubernetes.github.io/autoscaler"
        _releaseNamespace = _tenantNamespace
        _targetHelmProviderConfigName = _controlPlaneHelmProviderConfigName
        managedResource.spec.forProvider.skipCreateNamespace = True
        managedResource.spec.forProvider.values = {
            autoDiscovery = {
                namespace = _tenantNamespace
                clusterName = _clusterName
            }
            cloudProvider = "clusterapi"
            clusterAPIMode = "kubeconfig-incluster"
            clusterAPIKubeconfigSecret = _clusterKubeconfigSecretName
            rbac = {
                clusterScoped = False
            }
        }
    }
    managedResources: [core.ManagedResource] = [
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRelease.usages

