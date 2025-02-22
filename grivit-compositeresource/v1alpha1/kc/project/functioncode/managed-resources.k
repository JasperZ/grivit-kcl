import grivit_library.composite.v1alpha1 as composite
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

kcProject: composite.KcProject = composite.KcProject {
    _domain = spec.domain
    _instanceName = spec.instanceName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
    _realmId = spec.realmId
}

details = []

items = details + kcProject.managedResources + kcProject.usages
