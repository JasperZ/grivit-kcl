import base64
import composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

osStage: composite.OsStage = composite.OsStage {
    _controlPlaneK8sProviderConfigName = spec.controlPlaneK8sProviderConfigName
    _controlPlaneOsProviderConfigName = spec.controlPlaneOsProviderConfigName
    _domain = spec.domain
    _email = spec.email
    _name = claimName
    _observedComposedResources = observedComposedResources
    _projectName = spec.projectName
    _tenantNamespace = claimNamespace
}

details = [
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "CompositeConnectionDetails"
        data: {
            osProviderConfigName = base64.encode(osStage.providerConfig.managedResource.metadata.name)
        }
    }
]

items = details + osStage.managedResources + osStage.usages
