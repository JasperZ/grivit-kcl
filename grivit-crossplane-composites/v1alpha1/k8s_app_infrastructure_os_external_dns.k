import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux
import api.cp.os.v1 as cpOs
import base64

schema K8sAppInfrastructureOsExternalDNS:
    _name: str
    _clusterName: str
    _controlPlaneK8sProviderConfigName: str
    _domainFilters: [str]
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _targetOsProviderConfigName: str
    _tenantNamespace: str
    _observedCompositeResource: any

    applicationCredential: cpOs.IdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes-sigs.github.io/external-dns"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    _applicationCredentialId: str = ""
    _applicationCredentialSecret: str = ""
    _applicationCredentialName: str = applicationCredential.managedResource.metadata.name
    if _applicationCredentialName in _observedCompositeResource:
        _applicationCredentialId = str(_observedCompositeResource[_applicationCredentialName].Resource?.status?.atProvider?.id or "")
        _applicationCredentialSecret = base64.decode(_observedCompositeResource[_applicationCredentialName].ConnectionDetails["attribute.secret"] or base64.encode("dummy"))

    helmRelease: cpK8sFlux.HelmReleaseWrapper {
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
                    value = _applicationCredentialId
                }
                {
                    name = "OS_APPLICATION_CREDENTIAL_SECRET"
                    value = _applicationCredentialSecret
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
    managedResources: [cpCore.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

