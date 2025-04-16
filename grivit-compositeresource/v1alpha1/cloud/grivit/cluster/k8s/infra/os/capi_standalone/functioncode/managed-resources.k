import grivit_library.composite.v1alpha1.cluster.k8s.infra.os as cluster_k8s_infra

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
composite: str = observedComposedResources.metadata.labels["crossplane.io/composite"]
spec: any = observedCompositeResource.spec

k8sClusterOsStandalone: cluster_k8s_infra.CapiStandaloneClusterK8sInfraOs = cluster_k8s_infra.CapiStandaloneClusterK8sInfraOs {
    _claimNamespace = claimNamespace
    _claimName = claimName
    _clusterName = spec.clusterName
    _composite = composite
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
    _workers = {
        flavorName = spec.workers.flavor
        rootVolumeSize = spec.workers.rootVolumeSize
        autoscaling = {
            maxSize = spec.workers.autoscaling.maxSize
            minSize = spec.workers.autoscaling.minSize
        }
    }
}

items = k8sClusterOsStandalone.managedResources + k8sClusterOsStandalone.usages
