import core.v1alpha1 as core

schema OpenStackCloudControllerManager:
    _clusterName: str
    _clusterSubnetId: str
    _externalNetworkId: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
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
        _helmChartName = "openstack-cloud-controller-manager"
        _helmChartVersion = "2.30.2"
        _helmReleaseName = "openstack-cloud-controller-manager"
        _helmReleaseNamespace = "kube-system"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            cloudConfig = {
                name = "occm-cloud-config"
                global = {
                    # ToDo: hard coded url
                    "auth-url" = "https://test.grivit.cloud:5000"
                    "application-credential-id" = applicationCredential.getApplicationCredentialId(_observedComposedResources)
                    "application-credential-secret" = applicationCredential.getApplicationCredentialSecret(_observedComposedResources)
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
            resources = {
                limits.cpu = "150m"
                limits.memory = "128Mi"
                requests.cpu = "150m"
                requests.memory = "128Mi"
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
    managedResources: [core.ManagedResource] = [
        applicationCredential.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = applicationCredential.usages + helmRepo.usages + helmRelease.usages

