import xresources.v1alpha1 as res

schema K8sAppCrdPrometheusOperator:
    _name: str

    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: res.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://prometheus-community.github.io/helm-charts"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: res.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "prometheus-operator-crds"
        _helmChartVersion = "14.0.0"
        _helmReleaseName = "prometheus-operator-crds"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [res.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [res.Usage] = helmRepo.usages + helmRelease.usages

