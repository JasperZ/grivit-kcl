import xresources.v1alpha1 as res

schema K8sAppInfrastructureCilium:
    _name: str
    _fluxHelmReleaseDependencies?: [res.K8sFluxHelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: res.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://helm.cilium.io"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: res.K8sFluxHelmReleaseWrapper {
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
    managedResources: [res.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [res.Usage] = helmRepo.usages + helmRelease.usages

