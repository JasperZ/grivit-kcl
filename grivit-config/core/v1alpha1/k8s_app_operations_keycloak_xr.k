import grivit_library.core.v1alpha1 as glcore

schema k8sAppOperationsKeycloakXr(glcore.Composition):
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
import grivit_library.core.v1alpha1 as glcore

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

_targetK8sProviderConfigWrapper: glcore.K8sProviderConfigWrapper = glcore.K8sProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.k8sClusterK8sProviderConfig:
    resource = extraResources?.k8sClusterK8sProviderConfig[0]?.Resource

    _targetK8sProviderConfigWrapper = glcore.K8sProviderConfigWrapper {
        _name = resource?.metadata?.name or ""
        _credentialsSecretName = resource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = resource?.spec?.credentials?.secretRef?.namespace or ""
    }

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sAppOperationsKeycloak: glcomp.K8sAppOperationsKeycloak = glcomp.K8sAppOperationsKeycloak {
    _adminPassword = spec.adminPassword
    _controlPlaneK8sProviderConfigName = spec.controlPlaneK8sProviderConfigName
    _domain = spec.domain
    _name = claimName
    _targetK8sProviderConfigWrapper = _targetK8sProviderConfigWrapper
    _tenantNamespace = claimNamespace
}

details = [
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            k8sClusterK8sProviderConfig = {
                apiVersion: "kubernetes.crossplane.io/v1alpha1",
                kind: "ProviderConfig",
                matchLabels: {
                    "crossplane.io/claim-name": spec.k8sClusterRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + k8sAppOperationsKeycloak.managedResources + k8sAppOperationsKeycloak.usages
"""
            }
            glcore.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }

