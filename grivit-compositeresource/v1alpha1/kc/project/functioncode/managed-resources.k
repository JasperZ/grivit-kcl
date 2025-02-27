import grivit_library.composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

kcProject: composite.KcProject = composite.KcProject {
    _domain = spec.domain
    _instanceName = spec.instanceName
    _instanceOwnerProjectName = spec.instanceOwnerProjectName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
    _realmId = spec.realmId
}

items = sum([
    kcProject.managedResources
    kcProject.usages
], [])
