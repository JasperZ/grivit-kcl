import xresources.v1alpha1 as res
import base64

schema K8sAppInfrastructureOsCloudControllerManager:
    _name: str
    _fluxHelmReleaseDependencies?: [res.K8sFluxHelmReleaseWrapper]
    _clusterName: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _targetOsProviderConfigName: str
    _observedCompositeResource: any
    _clusterSubnetId: str
    _externalNetworkId: str

    applicationCredential: res.OsIdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _tenantNamespace = _tenantNamespace
        _targetOsProviderConfigName = _targetOsProviderConfigName
    }
    helmRepo: res.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes.github.io/cloud-provider-openstack"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    _applicationCredentialId: str = ""
    _applicationCredentialSecret: str = ""
    _applicationCredentialName: str = applicationCredential.managedResource.metadata.name
    if _applicationCredentialName in _observedCompositeResource:
        _applicationCredentialId = str(_observedCompositeResource[_applicationCredentialName].Resource?.status?.atProvider?.id or "")
        _applicationCredentialSecret = base64.decode(_observedCompositeResource[_applicationCredentialName].ConnectionDetails["attribute.secret"] or base64.encode("dummy"))

    helmRelease: res.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "openstack-cloud-controller-manager"
        _helmChartVersion = "2.30.2"
        _helmReleaseName = "openstack-cloud-controller-manager"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            cloudConfig = {
                name = "occm-cloud-config"
                global = {
                    # ToDo: hard coded url
                    "auth-url" = "https://test.grivit.cloud:5000"
                    "application-credential-id" = _applicationCredentialId
                    "application-credential-secret" = _applicationCredentialSecret
                }
                loadBalancer = {
                    "subnet-id" = _clusterSubnetId
                    "floating-network-id" = _externalNetworkId
                    "lb-provider" = "ovn"
                    "lb-method" = "SOURCE_IP_PORT"
                    "create-monitor" = True
                }
            }
            cluster = {
                name = _clusterName
            }
            nodeSelector = {
                "node-role.kubernetes.io/control-plane" = ""
            }
            tolerations = [
                {
                    key = "node.cloudprovider.kubernetes.io/uninitialized"
                    value = "true"
                    effect = "NoSchedule"
                }
                {
                    key = "node-role.kubernetes.io/control-plane"
                    value = ""
                    effect = "NoSchedule"
                }
                {
                    key = "node.kubernetes.io/not-ready"
                    value = ""
                    effect = "NoSchedule"
                }
            ]
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [res.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [res.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

