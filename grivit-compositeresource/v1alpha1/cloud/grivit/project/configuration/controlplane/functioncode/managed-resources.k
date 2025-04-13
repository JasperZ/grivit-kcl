import grivit_library.composite.v1alpha1.project.configuration as proj_conf

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

xpControlPlaneProject: proj_conf.ControlPlaneProjectConfiguration = proj_conf.ControlPlaneProjectConfiguration {
    _contactEmail = spec.contactEmail
    _domain = spec.domain
    _k8sClusterName = "ctrl"
    _observedComposedResources = observedComposedResources
    _claimNamespace = claimNamespace
}

items = sum([
    xpControlPlaneProject.managedResources
    xpControlPlaneProject.usages
], [])
