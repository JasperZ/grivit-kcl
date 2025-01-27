import xresources.v1alpha1 as res

schema K8sAppInfrastructureOsExternalDNS:
    _name: str
    _clusterName: str
    _controlPlaneK8sProviderConfigName: str
    _domainFilters: [str]
    _fluxHelmReleaseDependencies?: [res.K8sFluxHelmReleaseWrapper]
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _targetOsProviderConfigName: str
    _tenantNamespace: str
    _observedCompositeResource: any

    applicationCredential: res.OsIdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRepo: res.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes-sigs.github.io/external-dns"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: res.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "external-dns"
        _helmChartVersion = "1.14.5"
        _helmReleaseName = "external-dns"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
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
                    value = applicationCredential.getApplicationCredentialId(_observedCompositeResource)
                }
                {
                    name = "OS_APPLICATION_CREDENTIAL_SECRET"
                    value = applicationCredential.getApplicationCredentialSecret(_observedCompositeResource)
                }
            ]
            extraArgs = ["--txt-wildcard-replacement=wildcard"]
            txtOwnerId = _clusterName
            policy = "sync"
            provider = "designate"
            sources = ["service", "ingress"]
            logLevel = "debug"
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [res.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [res.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

