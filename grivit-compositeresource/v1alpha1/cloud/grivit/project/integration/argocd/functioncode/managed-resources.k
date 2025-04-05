import grivit_library.composite.v1alpha1.project.integration as integrations
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdInstance: core.ArgoCdInstance {
    domain = spec.argoCdDomain
    name = spec.argoCdInstanceName
    ownerProjectName = spec.argoCdInstanceOwnerProjectName
    projectName = "instance"
}

keycloakInstance: core.KeycloakInstance {
    domain = spec.keycloakDomain
    name = spec.keycloakInstanceName
    ownerProjectName = spec.keycloakInstanceOwnerProjectName
    realmId = claimNamespace
}

argoCdProjectIntegration: integrations.ArgoCdProjectIntegration = integrations.ArgoCdProjectIntegration {
    _argoCdInstance = argoCdInstance
    _claimName = claimName
    _claimNamespace = claimNamespace
    _keycloakInstance = keycloakInstance
    _observedComposedResources = observedComposedResources
    _targetProjectName = spec.targetProjectName
}

items = sum([
    argoCdProjectIntegration.managedResources
    argoCdProjectIntegration.usages
], [])
