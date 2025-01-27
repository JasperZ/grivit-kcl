import core.v1alpha1 as core

schema K8sAppInfrastructureCilium:
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://helm.cilium.io"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "cilium"
        _helmChartVersion = "1.16.2"
        _helmReleaseName = "cilium"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            ipam = {
                operator = {
                    clusterPoolIPv4MaskSize = 24
                    clusterPoolIPv4PodCIDRList = ["192.168.0.0/16"]
                }
            }
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

