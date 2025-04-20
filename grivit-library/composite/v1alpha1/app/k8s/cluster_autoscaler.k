import core.v1alpha1 as core

schema ClusterAutoscalerAppK8s:
    _clusterName: str
    _name: str
    _projectNamespace: str

    helmRelease: core.HelmReleaseWrapper {
        _clusterName = _clusterName
        _chartName = "cluster-autoscaler"
        _chartVersion = "9.40.0"
        _chartRepoUrl = "https://kubernetes.github.io/autoscaler"
        _name = _name
        _projectNamespace = _projectNamespace
        _targetNamespace = _projectNamespace
        managedResource.spec.forProvider.skipCreateNamespace = True
        managedResource.spec.forProvider.values = {
            autoDiscovery = {
                namespace = _projectNamespace
                clusterName = _clusterName
            }
            cloudProvider = "clusterapi"
            clusterAPIMode = "kubeconfig-incluster"
            clusterAPIKubeconfigSecret = "${_projectNamespace}-k8s-${_clusterName}-provider"
            resources = {
                limits.cpu = "100m"
                limits.memory = "128Mi"
                requests.cpu = "100m"
                requests.memory = "128Mi"
            }
            rbac = {
                clusterScoped = False
            }
        }
    }
    managedResources: [core.ManagedResource] = [
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRelease.usages

