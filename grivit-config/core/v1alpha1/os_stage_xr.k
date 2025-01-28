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
        compositeTypeRef.kind = _nameSingular
        pipeline: [
            glcore.CompositionSpecPipelineStepKcl {
                step = "managed-resources"
                input.spec.dependencies = 'grivit-library = { git = "https://github.com/JasperZ/grivit-kcl.git", branch = "main", version = "0.0.1" }'
                input.spec.source = """\
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
    _observedCompositeResource = observedComposedResources
    _projectName = spec.projectName
    _tenantNamespace = claimNamespace
}

items = osStage.managedResources + osStage.usages

"""
            }
            glcore.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }

