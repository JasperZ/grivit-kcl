import xresources.v1alpha1 as res

schema K8sAppBundleCrds:
    _clusterName: str

    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _tenantNamespace: str

    k8sAppsCRDsPrometheusOperator: K8sAppCrdPrometheusOperator {
        _name = "${_clusterName}-crd-prom"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
    }
    fluxHelmReleases: [res.K8sFluxHelmReleaseWrapper] = [
        k8sAppsCRDsPrometheusOperator.helmRelease
    ]

    managedResources: [res.ManagedResource] = k8sAppsCRDsPrometheusOperator.managedResources
    usages: [res.Usage] = k8sAppsCRDsPrometheusOperator.usages

