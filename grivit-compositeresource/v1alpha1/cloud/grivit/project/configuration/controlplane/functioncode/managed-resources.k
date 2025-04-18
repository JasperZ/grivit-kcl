import grivit_library.composite.v1alpha1.project.configuration as config

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

controlPlaneProjectConfiguration: config.ControlPlaneProjectConfiguration = config.ControlPlaneProjectConfiguration {
    _claimName = claimName
    _claimNamespace = claimNamespace
    _contactEmail = spec.contactEmail
    _domain = spec.domain
    _k8sClusterName = "ctrl"
    _observedComposedResources = observedComposedResources
}

items = sum([
    controlPlaneProjectConfiguration.managedResources
    controlPlaneProjectConfiguration.usages
], [])
