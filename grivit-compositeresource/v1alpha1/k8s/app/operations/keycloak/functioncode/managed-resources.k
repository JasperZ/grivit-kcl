import grivit_library.composite.v1alpha1 as composite
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sAppOperationsKeycloak: composite.K8sAppOperationsKeycloak = composite.K8sAppOperationsKeycloak {
    _adminPassword = spec.adminPassword
    _clusterName = spec.k8sClusterName
    _domain = spec.domain
    _instanceName = spec.instanceName
    _name = claimName
    _projectNamespace = claimNamespace
}

details = []

items = details + k8sAppOperationsKeycloak.managedResources + k8sAppOperationsKeycloak.usages
