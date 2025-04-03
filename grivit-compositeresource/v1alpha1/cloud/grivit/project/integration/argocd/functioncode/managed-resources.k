import grivit_library.composite.v1alpha1.project.integration as integrations

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdProjectIntegration: integrations.ArgoCdProjectIntegration = integrations.ArgoCdProjectIntegration {
    _argoCdDomain = spec.argoCdDomain
    _argoCdInstanceName = spec.argoCdInstanceName
    _argoCdInstanceOwnerProjectName = spec.argoCdInstanceOwnerProjectName
    _argoCdProjectName = claimNamespace
    _claimNamespace = claimNamespace
    _keycloakDomain = spec.keycloakDomain
    _keycloakInstanceName = spec.keycloakInstanceName
    _keycloakInstanceOwnerProjectName = spec.keycloakInstanceOwnerProjectName
    _keycloakRealmId = claimNamespace
    _observedComposedResources = observedComposedResources
    _targetProjectName = spec.targetProjectName
}

items = sum([
    argoCdProjectIntegration.managedResources
    argoCdProjectIntegration.usages
], [])
