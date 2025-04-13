import crypto
import core.v1alpha1 as core

schema ClusterApiAppK8s:
    _claimName: str
    _claimNamespace: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _kubernetesClusterName: str

    _managedResourcePrefix = "g-" + crypto.md5("${_claimNamespace}-${_claimName}") + "-cluster-api-"

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_managedResourcePrefix}repo"
        _helmRepoUrl = "https://kubernetes-sigs.github.io/cluster-api-operator"
        _projectNamespace = _claimNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _kubernetesClusterName
        _name = "${_managedResourcePrefix}rel"
        _helmChartName = "cluster-api-operator"
        _helmChartVersion = "0.14.0"
        _helmReleaseName = "cluster-api-operator"
        _helmReleaseNamespace = "capi-operator-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _claimNamespace
        managedResource.spec.forProvider.manifest.spec.persistentClient = False
        managedResource.spec.forProvider.manifest.spec.values = {
            infrastructure = "openstack"
        }
    }
    
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]
    usages: [core.Usage] = sum([
        helmRepo.usages
        helmRelease.usages
    ], [])


    check:
        len(managedResources) == len({managedResource.metadata.name: True for managedResource in managedResources}), "Names of managed Resources must be unique"