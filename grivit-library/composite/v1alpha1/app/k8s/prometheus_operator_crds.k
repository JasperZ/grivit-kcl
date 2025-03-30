import core.v1alpha1 as core

schema PrometheusOperatorCrds:
    _clusterName: str
    _name: str
    _projectNamespace: str

    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://prometheus-community.github.io/helm-charts"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "prometheus-operator-crds"
        _helmChartVersion = "14.0.0"
        _helmReleaseName = "prometheus-operator-crds"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages
