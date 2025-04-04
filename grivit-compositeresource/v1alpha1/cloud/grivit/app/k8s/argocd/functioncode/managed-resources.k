import grivit_library.composite.v1alpha1.app.k8s as apps

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdAppK8s: apps.ArgoCdAppK8s = apps.ArgoCdAppK8s {
    _argoCdDomain = spec.argoCdDomain
    _argoCdInstanceName = spec.argoCdInstanceName
    _argoCdInstanceOwnerProjectName = claimNamespace
    _argoCdProjectName = "instance"
    _claimNamespace = claimNamespace
    _keycloakDomain = spec.keycloakDomain
    _keycloakInstanceName = spec.keycloakInstanceName
    _keycloakInstanceOwnerProjectName = spec.keycloakInstanceOwnerProjectName
    _keycloakRealmId = spec.keycloakRealmId
    _kubernetesClusterName = spec.kubernetesClusterName
    _observedComposedResources = observedComposedResources
}

items = sum([
    argoCdAppK8s.managedResources
    argoCdAppK8s.usages
], [])
