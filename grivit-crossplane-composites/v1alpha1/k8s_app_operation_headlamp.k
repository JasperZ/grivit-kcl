import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppOperationHeadlamp:
    _name: str
    _domain: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://headlamp-k8s.github.io/headlamp"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: cpK8sFlux.HelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "headlamp"
        _helmChartVersion = "0.27.0"
        _helmReleaseName = "headlamp"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            config = {
                pluginsDir = "/build/plugins"
            }
            ingress = {
                enabled = True
                annotations = {
                    "cert-manager.io/cluster-issuer" = "letsencrypt"
                }
                ingressClassName = "nginx"
                hosts = [
                    {
                        host = _domain
                        paths = [
                            {
                                path = "/"
                                type = "Prefix"
                            }
                        ]
                    }
                ]
                tls = [
                    {
                        secretName = "${_domain}-tls"
                        hosts = [_domain]
                    }
                ]
            }
            initContainers = [
                {
                    command = [
                        "/bin/sh"
                        "-c"
                        "mkdir -p /build/plugins && cp -r /plugins/* /build/plugins/"
                    ]
                    image = "ghcr.io/headlamp-k8s/headlamp-plugin-flux:latest"
                    imagePullPolicy = "Always"
                    name = "headlamp-plugins"
                    volumeMounts = [
                        {
                            mountPath = "/build/plugins"
                            name = "headlamp-plugins"
                        }
                    ]
                }
            ]
            persistentVolumeClaim = {
                accessModes = ["ReadWriteOnce"]
                enabled = True
                size = "1Gi"
            }
            volumeMounts = [
                {
                    mountPath = "/build/plugins"
                    name = "headlamp-plugins"
                }
            ]
            volumes = [
                {
                    name = "headlamp-plugins"
                    persistentVolumeClaim = {
                        claimName = "headlamp"
                    }
                }
            ]
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [cpCore.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = helmRepo.usages + helmRelease.usages

