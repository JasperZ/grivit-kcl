import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux
import api.cp.os.v1 as cpOs
import base64

schema K8sAppInfrastructureOsCSIDriver:
    _name: str
    _fluxHelmReleaseDependencies?: [cpK8sFlux.HelmReleaseWrapper]
    _clusterName: str
    _tenantNamespace: str
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _targetOsProviderConfigName: str
    _observedCompositeResource: any

    applicationCredential: cpOs.IdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _tenantNamespace = _tenantNamespace
        _targetOsProviderConfigName = _targetOsProviderConfigName
    }
    helmRepo: cpK8sFlux.HelmRepositoryWrapper {
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

    helmRelease: cpK8sFlux.HelmReleaseWrapper {
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
application-credential-id=${_applicationCredentialId}
application-credential-secret=${_applicationCredentialSecret}
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
    managedResources: [cpCore.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [cpCore.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

