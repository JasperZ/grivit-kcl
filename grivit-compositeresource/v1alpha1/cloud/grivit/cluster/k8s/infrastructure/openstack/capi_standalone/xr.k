import file
import grivit_library.core.v1alpha1 as core

schema XrCapiStandaloneClusterK8sInfrastructureOpenStack(core.Composition):
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
                input.spec.dependencies = 'grivit-library = { git = "https://github.com/JasperZ/grivit-kcl.git", branch = "unify-provider-naming", version = "0.0.2" }'
                input.spec.source = file.read(filepath="${file.modpath()}/v1alpha1/cloud/grivit/cluster/k8s/infrastructure/openstack/capi_standalone/functioncode/managed-resources.k")
            }
            core.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }
