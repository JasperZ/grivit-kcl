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
            cni = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
            envoy = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "128Mi"
                    requests.cpu = "50m"
                    requests.memory = "128Mi"
                }
            }
            ipam = {
                operator = {
                    clusterPoolIPv4MaskSize = 24
                    clusterPoolIPv4PodCIDRList = ["192.168.0.0/16"]
                }
            }
            operator = {
                resources = {
                    limits.cpu = "100m"
                    limits.memory = "128Mi"
                    requests.cpu = "100m"
                    requests.memory = "128Mi"
                }
            }
            resources = {
                limits.cpu = "50m"
                limits.memory = "256Mi"
                requests.cpu = "50m"
                requests.memory = "256Mi"
            }
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

