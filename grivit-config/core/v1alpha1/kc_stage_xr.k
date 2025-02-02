import grivit_library.core.v1alpha1 as glcore

schema KcStageXr(glcore.Composition):
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
import grivit_library.core.v1alpha1 as glcore

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

_targetKcProviderConfigWrapper: glcore.KcProviderConfigWrapper = glcore.KcProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.k8sAppOperationsKeycloakK8sProviderConfig:
    resource = extraResources?.k8sAppOperationsKeycloakK8sProviderConfig[0]?.Resource

    _targetKcProviderConfigWrapper = glcore.KcProviderConfigWrapper {
        _name = resource?.metadata?.name or ""
        _credentialsSecretName = resource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = resource?.spec?.credentials?.secretRef?.namespace or ""
    }

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

kcStage: glcomp.KcStage = glcomp.KcStage {
    _controlPlaneK8sProviderConfigName = spec.controlPlaneK8sProviderConfigName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _realmName = spec.realmName
    _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
    _tenantNamespace = claimNamespace
}

details = [
    # {
    #     apiVersion: "meta.krm.kcl.dev/v1alpha1"
    #     kind: "CompositeConnectionDetails"
    #     data: {
    #         kcProviderConfigName = base64.encode(kcStage.providerConfig.managedResource.metadata.name)
    #     }
    # }
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            k8sAppOperationsKeycloakK8sProviderConfig = {
                apiVersion: "keycloak.crossplane.io/v1beta1",
                kind: "ProviderConfig",
                matchLabels: {
                    "crossplane.io/claim-name": spec.k8sAppOperationsKeycloakClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + kcStage.managedResources + kcStage.usages
"""
            }
            glcore.CompositionSpecPipelineStepAutoReady {
                step = "automatically-detect-readiness"
            }
        ]
    }

