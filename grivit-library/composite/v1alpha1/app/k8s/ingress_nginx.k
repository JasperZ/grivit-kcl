import core.v1alpha1 as core

schema IngressNginx:
    _clusterName: str
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _projectNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes.github.io/ingress-nginx"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "ingress-nginx"
        _helmChartVersion = "4.11.2"
        _helmReleaseName = "ingress-nginx"
        _helmReleaseNamespace = "ingress-nginx"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            controller = {
                allowSnippetAnnotations = True
                config = {}
                metrics.enabled = True
                metrics.serviceMonitor.enabled = True
                replicaCount = 3
                service.type = "LoadBalancer"
                service.externalTrafficPolicy = "Local"
                resources.limits.cpu = "150m"
                resources.limits.memory = "256Mi"
                resources.requests.cpu = "150m"
                resources.requests.memory = "256Mi"
                admissionWebhooks.patchWebhookJob.resources.limits.cpu = "200m"
                admissionWebhooks.patchWebhookJob.resources.limits.memory = "128Mi"
                admissionWebhooks.patchWebhookJob.resources.requests.cpu = "100m"
                admissionWebhooks.patchWebhookJob.resources.requests.memory = "64Mi"
            }
        }
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

