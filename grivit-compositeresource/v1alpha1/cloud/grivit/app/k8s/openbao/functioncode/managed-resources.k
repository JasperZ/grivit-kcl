import grivit_library.composite.v1alpha1.app.k8s as apps

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

openBaoK8sApp: apps.OpenBaoK8sApp = apps.OpenBaoK8sApp {
    _clusterName = spec.k8sClusterName
    _domain = spec.domain
    _instanceName = spec.instanceName
    _kcDomain = spec.kcDomain
    _kcInstanceName = spec.kcInstanceName
    _kcRealmId = spec.kcRealmId
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectNamespace = claimNamespace
}

items = sum([
    openBaoK8sApp.managedResources
    openBaoK8sApp.usages
], [])
