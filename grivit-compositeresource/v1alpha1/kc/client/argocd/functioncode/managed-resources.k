import grivit_library.composite.v1alpha1 as composite
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
extraResources: any = option("params")?.extraResources

_targetK8sProviderConfigWrapper: core.K8sProviderConfigWrapper = core.K8sProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.k8sClusterK8sProviderConfig:
    _k8sClusterK8sProviderConfigResource = extraResources?.k8sClusterK8sProviderConfig[0]?.Resource

    _targetK8sProviderConfigWrapper = core.K8sProviderConfigWrapper {
        _name = _k8sClusterK8sProviderConfigResource?.metadata?.name or ""
        _credentialsSecretName = _k8sClusterK8sProviderConfigResource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = _k8sClusterK8sProviderConfigResource?.spec?.credentials?.secretRef?.namespace or ""
    }

_targetKcProviderConfigWrapper: core.KcProviderConfigWrapper = core.KcProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.kcStageKcProviderConfig:
    _kcStageKcProviderConfigResource = extraResources?.kcStageKcProviderConfig[0]?.Resource

    _targetKcProviderConfigWrapper = core.KcProviderConfigWrapper {
        _name = _kcStageKcProviderConfigResource?.metadata?.name or ""
        _credentialsSecretName = _kcStageKcProviderConfigResource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = _kcStageKcProviderConfigResource?.spec?.credentials?.secretRef?.namespace or ""
    }


claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

kcStage: composite.KcClientArgoCd = composite.KcClientArgoCd {
    _clientId = spec.clientId
    _domain = spec.domain
    _name = claimName
    _observedComposedResources = observedComposedResources
    _realmId = spec.realmId
    _targetK8sProviderConfigWrapper = _targetK8sProviderConfigWrapper
    _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
    _tenantNamespace = claimNamespace
}

details = [
    {
        apiVersion: "meta.krm.kcl.dev/v1alpha1"
        kind: "ExtraResources"
        requirements = {
            k8sClusterK8sProviderConfig = {
                apiVersion: "kubernetes.crossplane.io/v1alpha1"
                kind: "ProviderConfig"
                matchLabels: {
                    "crossplane.io/claim-name": spec.k8sClusterClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
            kcStageKcProviderConfig = {
                apiVersion: "keycloak.crossplane.io/v1beta1"
                kind: "ProviderConfig"
                matchLabels: {
                    "crossplane.io/claim-name": spec.kcStageClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + kcStage.managedResources + kcStage.usages
