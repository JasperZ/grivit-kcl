import grivit_library.composite.v1alpha1.app.k8s as apps
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

keycloakInstance: core.KeycloakInstance {
    domain = spec.keycloakDomain
    name = spec.keycloakInstanceName
    ownerProjectName = claimNamespace
    realmId = "master"
}

keycloakAppK8s: apps.KeycloakAppK8s = apps.KeycloakAppK8s {
    _claimNamespace = claimNamespace
    _keycloakInstance = keycloakInstance
    _keycloakAdminPassword = spec.keycloakAdminPassword
    _kubernetesClusterName = spec.kubernetesClusterName
}

items = sum([
    keycloakAppK8s.managedResources
    keycloakAppK8s.usages
], [])
