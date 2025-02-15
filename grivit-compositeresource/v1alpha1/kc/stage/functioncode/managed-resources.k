import grivit_library.composite.v1alpha1 as composite
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

_k8sAppOperationsKeycloakSpecDomain = ""
if extraResources?.k8sAppOperationsKeycloak:
    _k8sAppOperationsKeycloakSpecDomain = extraResources?.k8sAppOperationsKeycloak[0]?.Resource?.spec?.domain or ""

_targetKcProviderConfigWrapper: core.KcProviderConfigWrapper = core.KcProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.k8sAppOperationsKeycloakK8sProviderConfig:
    resource = extraResources?.k8sAppOperationsKeycloakK8sProviderConfig[0]?.Resource

    _targetKcProviderConfigWrapper = core.KcProviderConfigWrapper {
        _name = resource?.metadata?.name or ""
        _credentialsSecretName = resource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = resource?.spec?.credentials?.secretRef?.namespace or ""
    }

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

kcStage: composite.KcStage = composite.KcStage {
    _controlPlaneK8sProviderConfigName = spec.controlPlaneK8sProviderConfigName
    _name = claimName
    _observedComposedResources = observedComposedResources
    _realmName = spec.realmName
    _targetKcDomain = _k8sAppOperationsKeycloakSpecDomain
    _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
    _tenantNamespace = claimNamespace
}

details = [
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            k8sAppOperationsKeycloak = {
                apiVersion: "k8s.grivit.cloud/v1alpha1"
                kind: "xAppOperationsKeycloak"
                matchLabels: {
                    "crossplane.io/claim-name": spec.k8sAppOperationsKeycloakClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
            k8sAppOperationsKeycloakK8sProviderConfig = {
                apiVersion: "keycloak.crossplane.io/v1beta1"
                kind: "ProviderConfig"
                matchLabels: {
                    "crossplane.io/claim-name": spec.k8sAppOperationsKeycloakClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + kcStage.managedResources + kcStage.usages
