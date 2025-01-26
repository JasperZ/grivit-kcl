import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppInfrastructureCilium:
    _name: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://helm.cilium.io"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: cpK8sFlux.HelmReleaseWrapper {
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
    managedResources: [cpCore.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = helmRepo.usages + helmRelease.usages

