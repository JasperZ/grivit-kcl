import grivit_library.composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

xpControlPlaneProject: composite.XpControlPlaneProject = composite.XpControlPlaneProject {
    _k8sClusterName = spec.k8sClusterName
    _projectNamespace = claimNamespace
}

items = sum([
    xpControlPlaneProject.managedResources
    xpControlPlaneProject.usages
], [])
