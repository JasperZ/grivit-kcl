schema K8sFluxHelmOciReleaseWrapper:
    _clusterName: str
    _name: str
    _helmReleaseName: str
    _helmReleaseNamespace: str
    _helmOciRepositoryWrapper: K8sFluxOciRepositoryWrapper
    _helmReleaseWrapperDependencies: [K8sFluxHelmReleaseWrapper | K8sFluxHelmOciReleaseWrapper] = []
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "helm.toolkit.fluxcd.io/v2"
            kind = "HelmRelease"
            metadata = {
                name = _name
                namespace = _projectNamespace
            }
            spec = {
                interval = "1m"
                timeout = "5m"
                chartRef = {
                    kind = "OCIRepository"
                    name = _helmOciRepositoryWrapper.managedResource.metadata.name
                    namespace = _projectNamespace
                }
                releaseName = _helmReleaseName
                targetNamespace = _helmReleaseNamespace
                storageNamespace = _helmReleaseNamespace
                install = {
                    createNamespace = True
                    remediation = {
                        retries = -1
                    }
                }
                kubeConfig = {
                    secretRef = {
                        name = "${_projectNamespace}-${_clusterName}-k8s-provider"
                    }
                }
                upgrade = {
                    remediation = {
                        retries = 3
                    }
                }
                test = {
                    enable = True
                }
                driftDetection = {
                    mode = "enabled"
                }
                dependsOn = [{
                    name = helmRelease.managedResource.spec.forProvider.manifest.metadata.name
                } for helmRelease in _helmReleaseWrapperDependencies]
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = "${_projectNamespace}-ctrl-k8s"
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${_projectNamespace}-${_clusterName}-k8s"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${_projectNamespace}-${_clusterName}-k8s"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = "kubernetes.crossplane.io/v1alpha1"
        spec.of.kind = "ProviderConfig"
        spec.of.resourceRef.name = "${_projectNamespace}-${_clusterName}-k8s"
    }] + [Usage {
        metadata.name = "${_name}-uses-${k8sFluxHelmReleaseDependency.managedResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${k8sFluxHelmReleaseDependency.managedResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = k8sFluxHelmReleaseDependency.managedResource.apiVersion
        spec.of.kind = k8sFluxHelmReleaseDependency.managedResource.kind
        spec.of.resourceRef.name = k8sFluxHelmReleaseDependency.managedResource.metadata.name
    } for k8sFluxHelmReleaseDependency in _helmReleaseWrapperDependencies]

