import grivit_library.composite.v1alpha1.project.integration as integrations

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

keycloakProjectIntegration: integrations.KeycloakProjectIntegration = integrations.KeycloakProjectIntegration {
    _keycloakDomain = spec.keycloakDomain
    _keycloakInstanceName = spec.keycloakInstanceName
    _keycloakInstanceOwnerProjectName = spec.keycloakInstanceOwnerProjectName
    _keycloakRealmName = spec.keycloakRealmName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
}

items = sum([
    keycloakProjectIntegration.managedResources
    keycloakProjectIntegration.usages
], [])
