import grivit_library.composite.v1alpha1.project.configuration as proj_conf

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

xpControlPlaneProject: proj_conf.TenantProjectConfiguration = proj_conf.TenantProjectConfiguration {
    _claimNamespace = claimNamespace
    _contactEmail = spec.contactEmail
    _domain = spec.domain
    _observedComposedResources = observedComposedResources
}

items = sum([
    xpControlPlaneProject.managedResources
    xpControlPlaneProject.usages
], [])
