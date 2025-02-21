import core.v1alpha1 as core

schema K8sAppBundleCrds:
    _clusterName: str
    _projectNamespace: str

    k8sAppCRDsPrometheusOperator: K8sAppCrdPrometheusOperator {
        _clusterName = _clusterName
        _name = "${_clusterName}-crd-prom"
        _projectNamespace = _projectNamespace
    }
    fluxHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        k8sAppCRDsPrometheusOperator.helmRelease
    ]

    managedResources: [core.ManagedResource] = k8sAppCRDsPrometheusOperator.managedResources
    usages: [core.Usage] = k8sAppCRDsPrometheusOperator.usages

