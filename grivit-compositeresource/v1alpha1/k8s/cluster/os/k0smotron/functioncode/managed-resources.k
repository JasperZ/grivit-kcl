import grivit_library.composite.v1alpha1 as composite

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

_kcStageKcProviderConfigName: str = ""
if extraResources?.kcStageComposition:
    _kcStageCompositionResourceName = extraResources?.kcStageComposition[0]?.Resource?.metadata?.name or ""
    _kcStageKcProviderConfigName = "${_kcStageCompositionResourceName}-kc-provider-config"

_osStageOsProviderConfigName: str = ""
if extraResources?.osStageComposition:
    _osStageCompositionResourceName = extraResources?.osStageComposition[0]?.Resource?.metadata?.name or ""
    _osStageOsProviderConfigName = "${_osStageCompositionResourceName}-os-provider-config"

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sClusterOsK0smotron: composite.K8sClusterOsK0smotron = composite.K8sClusterOsK0smotron {
    _controlPlane = {
        flavorName = spec.controlPlane.flavor
        rootVolumeSize = spec.controlPlane.rootVolumeSize
        replicas = spec.controlPlane.replicas
    }
    _controlPlaneAwsProviderConfigName = spec.controlPlaneAwsProviderConfigName
    _controlPlaneHelmProviderConfigName = spec.controlPlaneHelmProviderConfigName
    _controlPlaneK8sProviderConfigName = spec.controlPlaneK8sProviderConfigName
    _domain = spec.domain
    _email = spec.email
    _externalNetworkName = spec.externalNetworkName
    _headlampDomain = spec.headlampDomain
    _k8sVersion = spec.kubernetesVersion
    _name = claimName
    _observedComposedResources = observedComposedResources
    _targetOsProviderConfigName = _osStageOsProviderConfigName
    _tenantNamespace = claimNamespace
    _workers = {
        flavorName = spec.workers.flavor
        rootVolumeSize = spec.workers.rootVolumeSize
        autoscaling = {
            minSize = spec.workers.autoscaling.minSize
            maxSize = spec.workers.autoscaling.maxSize
        }
    }
}

details = [
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            kcStageComposition = {
                apiVersion: "kc.grivit.cloud/v1alpha1"
                kind: "xStage"
                matchLabels: {
                    "crossplane.io/claim-name": spec.kcStageClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
            osStageComposition = {
                apiVersion: "os.grivit.cloud/v1alpha1"
                kind: "xStage"
                matchLabels: {
                    "crossplane.io/claim-name": spec.osStageClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + k8sClusterOsK0smotron.managedResources + k8sClusterOsK0smotron.usages
