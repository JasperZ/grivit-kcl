import core.v1alpha1 as core

schema K8sAppOperationsHeadlamp:
    _clusterName: str
    _domain: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _projectNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://headlamp-k8s.github.io/headlamp"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "headlamp"
        _helmChartVersion = "0.27.0"
        _helmReleaseName = "headlamp"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
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
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

