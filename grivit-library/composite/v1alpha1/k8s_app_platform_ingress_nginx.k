import core.v1alpha1 as core

schema K8sAppPlatformIngressNginx:
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes.github.io/ingress-nginx"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
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
                allowSnippetAnnotations = True
                config = {}
                metrics.enabled = True
                metrics.serviceMonitor.enabled = True
                replicaCount = 3
                service.type = "LoadBalancer"
                service.externalTrafficPolicy = "Local"
                resources.limit.cpu = "150m"
                resources.limit.memory = "256Mi"
                resources.requests.cpu = "150m"
                resources.requests.memory = "256Mi"
                admissionWebhooks.patchWebhookJob.resources.limit.cpu = "200m"
                admissionWebhooks.patchWebhookJob.resources.limit.memory = "128Mi"
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

