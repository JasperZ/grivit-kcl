import core.v1alpha1 as core

schema K8sAppPlatformMetricsServer:
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes-sigs.github.io/metrics-server"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "metrics-server"
        _helmChartVersion = "3.12.1"
        _helmReleaseName = "metrics-server"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            args = ["--kubelet-insecure-tls"]
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

