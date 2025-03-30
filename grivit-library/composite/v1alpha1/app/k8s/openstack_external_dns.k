import core.v1alpha1 as core

schema OpenStackExternalDns:
    _clusterName: str
    _domainFilters: [str]
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _projectNamespace: str
    _observedComposedResources: any

    applicationCredential: core.OsIdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _projectNamespace = _projectNamespace
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes-sigs.github.io/external-dns"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "external-dns"
        _helmChartVersion = "1.14.5"
        _helmReleaseName = "external-dns"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            domainFilters = _domainFilters
            env = [
                {
                    name = "OS_AUTH_URL"
                    # ToDo: hard coded url
                    value = "https://test.grivit.cloud:5000/v3"
                }
                {
                    name = "OS_AUTH_TYPE"
                    value = "v3applicationcredential"
                }
                {
                    name = "OS_APPLICATION_CREDENTIAL_ID"
                    value = applicationCredential.getApplicationCredentialId(_observedComposedResources)
                }
                {
                    name = "OS_APPLICATION_CREDENTIAL_SECRET"
                    value = applicationCredential.getApplicationCredentialSecret(_observedComposedResources)
                }
            ]
            extraArgs = ["--txt-wildcard-replacement=wildcard"]
            txtOwnerId = _clusterName
            policy = "sync"
            provider = "designate"
            resources = {
                limits.cpu = "100m"
                limits.memory = "128Mi"
                requests.cpu = "100m"
                requests.memory = "128Mi"
            }
            sources = ["service", "ingress"]
            logLevel = "debug"
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

