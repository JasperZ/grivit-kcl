import grivit_library.composite.v1alpha1.cluster.k8s.infrastructure.openstack as cluster_k8s_infra

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sClusterOsStandalone: cluster_k8s_infra.CapiStandaloneClusterK8sInfrastructureOpenStack = cluster_k8s_infra.CapiStandaloneClusterK8sInfrastructureOpenStack {
    _controlPlane = {
        flavorName = spec.controlPlane.flavor
        replicas = spec.controlPlane.replicas
        rootVolumeSize = spec.controlPlane.rootVolumeSize
    }
    _domain = spec.domain
    _email = spec.email
    _externalNetworkName = spec.externalNetworkName
    _k8sVersion = spec.kubernetesVersion
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
    _workers = {
        flavorName = spec.workers.flavor
        rootVolumeSize = spec.workers.rootVolumeSize
        autoscaling = {
            minSize = spec.workers.autoscaling.minSize
            maxSize = spec.workers.autoscaling.maxSize
        }
    }
}

items = k8sClusterOsStandalone.managedResources + k8sClusterOsStandalone.usages
