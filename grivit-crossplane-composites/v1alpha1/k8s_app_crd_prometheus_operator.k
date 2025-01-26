import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppCrdPrometheusOperator:
    _name: str

    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://prometheus-community.github.io/helm-charts"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: cpK8sFlux.HelmReleaseWrapper {
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
    managedResources: [cpCore.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = helmRepo.usages + helmRelease.usages

