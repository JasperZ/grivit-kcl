import xresources.v1alpha1 as res

schema K8sAppInfrastructureOsCsiDriver:
    _name: str
    _fluxHelmReleaseDependencies?: [res.K8sFluxHelmReleaseWrapper]
    _clusterName: str
    _tenantNamespace: str
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _targetOsProviderConfigName: str
    _observedCompositeResource: any

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
    helmRelease: res.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "openstack-cinder-csi"
        _helmChartVersion = "2.31.2"
        _helmReleaseName = "openstack-cinder-csi"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            secret = {
                enabled = True
                create = True
                name = "openstack-cinder-csi-cloud-config"
                data = {
                    # ToDo: hard coded url
                    "cloud.conf" = """\
[Global]
auth-url=https://test.grivit.cloud:5000
application-credential-id=${applicationCredential.getApplicationCredentialId(_observedCompositeResource)}
application-credential-secret=${applicationCredential.getApplicationCredentialSecret(_observedCompositeResource)}
"""
                }
            }
            storageClass = {
                enables = True
                delete = {
                    isDefault = True
                    allowVolumeExpansion = True
                }
            }
            clusterID = _clusterName
            csi = {
                plugin = {
                    volumes = []
                    volumeMounts = [
                        {
                            name = "cloud-config"
                            mountPath = "/etc/kubernetes"
                            readOnly = True
                        }
                    ]
                }
            }
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [res.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [res.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

