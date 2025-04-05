import grivit_library.composite.v1alpha1.app.k8s as apps
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

argoCdInstance: core.ArgoCdInstance {
    domain = spec.argoCdDomain
    name = spec.argoCdInstanceName
    ownerProjectName = claimNamespace
    projectName = "instance"
}

keycloakInstance: core.KeycloakInstance {
    domain = spec.keycloakDomain
    name = spec.keycloakInstanceName
    ownerProjectName = spec.keycloakInstanceOwnerProjectName
    realmId = claimNamespace
}

argoCdAppK8s: apps.ArgoCdAppK8s = apps.ArgoCdAppK8s {
    _argoCdInstance = argoCdInstance
    _claimNamespace = claimNamespace
    _keycloakInstance = keycloakInstance
    _kubernetesClusterName = spec.kubernetesClusterName
    _observedComposedResources = observedComposedResources
}

items = sum([
    argoCdAppK8s.managedResources
    argoCdAppK8s.usages
], [])
