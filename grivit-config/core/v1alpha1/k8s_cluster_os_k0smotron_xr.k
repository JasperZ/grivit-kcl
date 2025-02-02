import grivit_library.core.v1alpha1 as glcore

schema k8sClusterOsK0smotronXr(glcore.Composition):
    _nameSingular: str
    _apiGroup: str
    _apiVersion: str

    metadata = {
        name = "${_nameSingular}.${_apiGroup}".lower()
    }
    spec = {
        compositeTypeRef.apiVersion = "${_apiGroup}/${_apiVersion}"
        compositeTypeRef.kind = "x${_nameSingular}"
        pipeline: [
            glcore.CompositionSpecPipelineStepKcl {
                step = "managed-resources"
                input.spec.dependencies = 'grivit-library = { git = "https://github.com/JasperZ/grivit-kcl.git", branch = "restructure", version = "0.0.1" }'
                input.spec.source = """\
import grivit_library.composites.v1alpha1 as glcomp

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

_kcStageKcProviderConfigName: str = ""
if extraResources?.kcStageComposition:
    name = extraResources?.kcStageComposition[0]?.Resource?.metadata?.name or ""
    _kcStageKcProviderConfigName = "\${name}-kc-provider-config"

_osStageOsProviderConfigName: str = ""
if extraResources?.osStageComposition:
    name = extraResources?.osStageComposition[0]?.Resource?.metadata?.name or ""
    _osStageOsProviderConfigName = "\${name}-os-provider-config"

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sClusterOsK0smotron: glcomp.K8sClusterOsK0smotron = glcomp.K8sClusterOsK0smotron {
    _argoCdDomain = spec.argoCdDomain
    _controlPlane = {
        flavorName = spec.controlPlane.flavor
        rootVolumeSize = spec.controlPlane.rootVolumeSize
        replicas = spec.controlPlane.replicas
    }
    _controlPlaneAwsProviderConfigName = spec.controlPlaneAwsProviderConfigName
    _controlPlaneHelmProviderConfigName = spec.controlPlaneHelmProviderConfigName
    _controlPlaneK8sProviderConfigName = spec.controlPlaneK8sProviderConfigName
    _domain = spec.domain
    _externalNetworkName = spec.externalNetworkName
    _headlampDomain = spec.headlampDomain
    _k8sVersion = spec.kubernetesVersion
    _name = claimName
    _observedComposedResources = observedComposedResources
    _realmId = spec.realmId
    _targetKcProviderConfigWrapper = _kcStageKcProviderConfigName
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
                apiVersion: "kc.grivit.cloud/v1alpha1",
                kind: "xStage",
                matchLabels: {
                    "crossplane.io/claim-name": spec.kcStageClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
            osStageComposition = {
                apiVersion: "os.grivit.cloud/v1alpha1",
                kind: "xStage",
                matchLabels: {
                    "crossplane.io/claim-name": spec.osStageClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + k8sClusterOsK0smotron.managedResources + k8sClusterOsK0smotron.usages
"""
            }
            glcore.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }

