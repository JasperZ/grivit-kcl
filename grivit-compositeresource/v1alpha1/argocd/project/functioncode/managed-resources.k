import grivit_library.composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdProject: composite.ArgoCdProject = composite.ArgoCdProject {
    _argoCdDomain = spec.argoCdDomain
    _argoCdInstanceName = spec.argoCdInstanceName
    _argoCdInstanceOwnerProjectName = spec.argoCdInstanceOwnerProjectName
    _kcDomain = spec.kcDomain
    _kcInstanceName = spec.kcInstanceName
    _kcInstanceOwnerProjectName = spec.kcInstanceOwnerProjectName
    _kcRealmId = spec.kcRealmId
    _observedComposedResources = observedComposedResources
    _projectName = spec.projectName
    _projectNamespace = claimNamespace
}

items = sum([
    argoCdProject.managedResources
    argoCdProject.usages
], [])
