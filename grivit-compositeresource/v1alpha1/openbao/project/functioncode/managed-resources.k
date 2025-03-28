import grivit_library.composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdProject: composite.OpenBaoProject = composite.OpenBaoProject {
    _observedComposedResources = observedComposedResources
    _openBaoDomain = spec.openBaoCdDomain
    _openBaoInstanceName = spec.openBaoInstanceName
    _openBaoInstanceOwnerProjectName = spec.openBaoInstanceOwnerProjectName
    _projectName = spec.projectName
    _projectNamespace = claimNamespace
}

items = sum([
    argoCdProject.managedResources
    argoCdProject.usages
], [])
