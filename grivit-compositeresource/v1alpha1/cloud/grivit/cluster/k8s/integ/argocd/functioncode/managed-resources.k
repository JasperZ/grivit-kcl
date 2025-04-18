import grivit_library.composite.v1alpha1.cluster.k8s.integ as integ

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
composite: str = observedCompositeResource.metadata.labels["crossplane.io/composite"]
spec: any = observedCompositeResource.spec

argoCdInstance: core.ArgoCdInstance {
    domain = "domain not required here"
    name = spec.argoCdInstanceName
    ownerProjectName = spec.argoCdInstanceOwnerProjectName
    projectName = claimNamespace
}

k8sCluster: core.K8sCluster {
    name = spec.k8sClusterName
    projectName = claimNamespace
}

argoCdIntegClusterK8s: integ.ArgoCdIntegClusterK8s = integ.ArgoCdIntegClusterK8s {
    _argoCdInstance = argoCdInstance
    _claimName = claimName
    _claimNamespace = claimNamespace
    _composite = composite
    _k8sCluster = k8sCluster
}

items = argoCdIntegClusterK8s.managedResources + argoCdIntegClusterK8s.usages
