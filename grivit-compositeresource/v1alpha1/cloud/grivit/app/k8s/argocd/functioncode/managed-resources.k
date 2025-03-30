import grivit_library.composite.v1alpha1.app.k8s as apps

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sAppOperationsArgoCd: apps.ArgoCd = apps.ArgoCd {
    _argoCdDomain = spec.argoCdDomain
    _argoCdInstanceName = spec.argoCdInstanceName
    _keycloakDomain = spec.keycloakDomain
    _keycloakInstanceName = spec.keycloakInstanceName
    _keycloakRealmId = spec.keycloakRealmId
    _kubernetesClusterName = spec.kubernetesClusterName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
}

items = sum([
    k8sAppOperationsArgoCd.managedResources
    k8sAppOperationsArgoCd.usages
], [])
