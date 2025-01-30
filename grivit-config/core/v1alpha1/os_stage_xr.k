import grivit_library.core.v1alpha1 as glcore

schema OsStageXr(glcore.Composition):
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
import base64
import grivit_library.composites.v1alpha1 as glcomp

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

osStage: glcomp.OsStage = glcomp.OsStage {
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
"""
            }
            glcore.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }

