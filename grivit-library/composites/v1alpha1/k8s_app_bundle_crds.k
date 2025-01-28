import core.v1alpha1 as core

schema K8sAppBundleCrds:
    _clusterName: str

    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    k8sAppsCRDsPrometheusOperator: K8sAppCrdPrometheusOperator {
        _name = "${_clusterName}-crd-prom"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppsCRDsPrometheusOperator.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppsCRDsPrometheusOperator.managedResources
    usages: [core.Usage] = k8sAppsCRDsPrometheusOperator.usages

