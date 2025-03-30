import core.v1alpha1 as core

schema OpenStackCinderCsi:
    _clusterName: str
    _name: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _observedComposedResources: any
    _projectNamespace: str

    applicationCredential: core.OsIdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _projectNamespace = _projectNamespace
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://kubernetes.github.io/cloud-provider-openstack"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "openstack-cinder-csi"
        _helmChartVersion = "2.31.2"
        _helmReleaseName = "openstack-cinder-csi"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            csi = {
                attacher.resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
                provisioner.resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
                snapshotter.resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
                resizer.resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
                livenessprobe.resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
                nodeDriverRegistrar.resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
                plugin = {
                    resources = {
                        limits.cpu = "50m"
                        limits.memory = "64Mi"
                        requests.cpu = "50m"
                        requests.memory = "64Mi"
                    }
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
            secret = {
                enabled = True
                create = True
                name = "openstack-cinder-csi-cloud-config"
                data = {
                    # ToDo: hard coded url
                    "cloud.conf" = """\
[Global]
auth-url=https://test.grivit.cloud:5000
application-credential-id=${applicationCredential.getApplicationCredentialId(_observedComposedResources)}
application-credential-secret=${applicationCredential.getApplicationCredentialSecret(_observedComposedResources)}
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
        }
        managedResource.spec.forProvider.manifest.spec.install.createNamespace = False
    }
    managedResources: [core.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

