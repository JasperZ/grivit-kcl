import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppPlatformIngressNginx:
    _name: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes.github.io/ingress-nginx"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: cpK8sFlux.HelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "ingress-nginx"
        _helmChartVersion = "4.11.2"
        _helmReleaseName = "ingress-nginx"
        _helmReleaseNamespace = "ingress-nginx"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            controller = {
                replicaCount = 3
                service = {
                    type = "LoadBalancer"
                    externalTrafficPolicy = "Local"
                }
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                allowSnippetAnnotations = True
                config = {}
            }
        }
    }
    managedResources: [cpCore.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = helmRepo.usages + helmRelease.usages

