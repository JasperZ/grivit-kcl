import core.v1alpha1 as core
import file

schema Xr(core.Composition):
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
            core.CompositionSpecPipelineStepKcl {
                step = "managed-resources"
                input.spec.dependencies = 'grivit = { git = "https://github.com/JasperZ/grivit-kcl.git", branch = "main", version = "0.0.1" }'
                input.spec.source = "import grivit.compositeresource.v1alpha1.kc.stage.functioncode"
            }
            core.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }

