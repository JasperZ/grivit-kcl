import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppBundleCrds:
    _clusterName: str

    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    k8sAppsCRDsPrometheusOperator: K8sAppCrdPrometheusOperator {
        _name = "${_clusterName}-crd-prom"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [cpK8sFlux.HelmReleaseWrapper] = [
        k8sAppsCRDsPrometheusOperator.helmRelease
    ]

    managedResources: [cpCore.ManagedResource] = k8sAppsCRDsPrometheusOperator.managedResources
    usages: [cpCore.Usage] = k8sAppsCRDsPrometheusOperator.usages

