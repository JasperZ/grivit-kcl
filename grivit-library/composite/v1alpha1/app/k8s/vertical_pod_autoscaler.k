import core.v1alpha1 as core

schema VerticalPodAutoscaler:
    _clusterName: str
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _projectNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://cowboysysop.github.io/charts"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "vertical-pod-autoscaler"
        _helmChartVersion = "9.8.3"
        _helmReleaseName = "vertical-pod-autoscaler"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            crds = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
            recommender = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
            resources = {
                limits.cpu = "50m"
                limits.memory = "64Mi"
                requests.cpu = "50m"
                requests.memory = "64Mi"
            }
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

