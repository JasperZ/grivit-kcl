import grivit_library.composite.v1alpha1.project.integration as integrations
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

keycloakInstance: core.KeycloakInstance {
    domain = spec.keycloakDomain
    name = spec.keycloakInstanceName
    ownerProjectName = spec.keycloakInstanceOwnerProjectName
    realmId = "master"
}

keycloakProjectIntegration: integrations.KeycloakProjectIntegration = integrations.KeycloakProjectIntegration {
    _claimNamespace = claimNamespace
    _keycloakInstance = keycloakInstance
    _observedComposedResources = observedComposedResources
    _targetProjectName = spec.targetProjectName
}

items = sum([
    keycloakProjectIntegration.managedResources
    keycloakProjectIntegration.usages
], [])
