import grivit_library.composite.v1alpha1 as composite
import grivit_library.core.v1alpha1 as core

observedComposedResources: any = option("params").ocds
observedCompositeResource: any = option("params").oxr
desiredCompositeResource: any = option("params").dxr
extraResources: any = option("params")?.extraResources

_targetK8sProviderConfigWrapper: core.K8sProviderConfigWrapper = core.K8sProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.k8sClusterK8sProviderConfig:
    k8sProviderConfigWrapperResource = extraResources?.k8sClusterK8sProviderConfig[0]?.Resource

    _targetK8sProviderConfigWrapper = core.K8sProviderConfigWrapper {
        _name = k8sProviderConfigWrapperResource?.metadata?.name or ""
        _credentialsSecretName = k8sProviderConfigWrapperResource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = k8sProviderConfigWrapperResource?.spec?.credentials?.secretRef?.namespace or ""
    }

_targetKcProviderConfigWrapper: core.KcProviderConfigWrapper = core.KcProviderConfigWrapper {
    _name = "dummy"
    _credentialsSecretName = "dummy"
    _credentialsSecretNamespace = "dummy"
}

if extraResources?.kcClusterK8sProviderConfig:
    kcProviderConfigWrapperResource = extraResources?.kcClusterK8sProviderConfig[0]?.Resource

    _targetKcProviderConfigWrapper = core.KcProviderConfigWrapper {
        _name = kcProviderConfigWrapperResource?.metadata?.name or ""
        _credentialsSecretName = kcProviderConfigWrapperResource?.spec?.credentials?.secretRef?.name or ""
        _credentialsSecretNamespace = kcProviderConfigWrapperResource?.spec?.credentials?.secretRef?.namespace or ""
    }

claimName: str = observedCompositeResource.metadata.name
claimNamespace: str = observedCompositeResource.metadata.labels["crossplane.io/claim-namespace"]
spec: any = observedCompositeResource.spec

k8sAppOperationsKeycloak: composite.K8sAppOperationsKeycloak = composite.K8sAppOperationsKeycloak {
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
                    "crossplane.io/claim-name": spec.k8sClusterClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
            kcClusterK8sProviderConfig = {
                apiVersion: "keycloak.crossplane.io/v1beta1",
                kind: "ProviderConfig",
                matchLabels: {
                    "crossplane.io/claim-name": spec.kcClusterClaimRef.name
                    "crossplane.io/claim-namespace": claimNamespace
                }
            }
        }
    }
]

items = details + k8sAppOperationsKeycloak.managedResources + k8sAppOperationsKeycloak.usages