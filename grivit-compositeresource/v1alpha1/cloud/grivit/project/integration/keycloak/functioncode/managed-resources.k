import grivit_library.composite.v1alpha1.project.integration as integrations

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

kcProject: integrations.Keycloak = integrations.Keycloak {
    _keycloakDomain = spec.keycloakDomain
    _keycloakInstanceName = spec.keycloakInstanceName
    _keycloakInstanceOwnerProjectName = spec.keycloakInstanceOwnerProjectName
    _keycloakRealmName = spec.keycloakRealmName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
}

items = sum([
    kcProject.managedResources
    kcProject.usages
], [])
