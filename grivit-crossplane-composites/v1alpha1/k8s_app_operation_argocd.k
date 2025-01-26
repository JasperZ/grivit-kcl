import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppOperationArgoCd:
    _name: str
    _domain: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://argoproj.github.io/argo-helm"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: cpK8sFlux.HelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "argo-cd"
        _helmChartVersion = "7.7.10"
        _helmReleaseName = "argocd"
        _helmReleaseNamespace = "argocd"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            applicationSet = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
            }
            configs.params = {
                "server.insecure" = True
            }
            controller = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
            }
            dex.enabled = False
            redi.metrics = {
                enabled = True
                serviceMonitor = {
                    enabled = True
                }
            }
            global.domain = _domain
            notifications.metrics = {
                enabled = True
                serviceMonitor = {
                    enabled = True
                }
            }
            repoServer = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
            }
            server = {
                ingress = {
                    annotations = {
                        "cert-manager.io/cluster-issuer" = "letsencrypt"
                    }
                    enabled = True
                    ingressClassName = "nginx"
                    tls = True
                }
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
            }
        }
    }
    managedResources: [cpCore.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = helmRepo.usages + helmRelease.usages

