import grivit_library.composite.v1alpha1.app.k8s as apps

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

keycloakAppK8s: apps.KeycloakAppK8s = apps.KeycloakAppK8s {
    _keycloakAdminPassword = spec.keycloakAdminPassword
    _keycloakDomain = spec.keycloakDomain
    _keycloakInstanceName = spec.keycloakInstanceName
    _kubernetesClusterName = spec.kubernetesClusterName
    _name = claimName
    _projectNamespace = claimNamespace
}

items = sum([
    keycloakAppK8s.managedResources
    keycloakAppK8s.usages
], [])
