import grivit_library.composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdProject: composite.ArgoCdProject = composite.ArgoCdProject {
    _argoCdDomain = spec.argoCdDomain
    _argoCdInstanceName = spec.argoCdInstanceName
    _kcDomain = spec.kcDomain
    _kcInstanceName = spec.kcInstanceName
    _kcRealmId = spec.kcRealmId
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
}

items = sum([
    argoCdProject.managedResources
    argoCdProject.usages
], [])
