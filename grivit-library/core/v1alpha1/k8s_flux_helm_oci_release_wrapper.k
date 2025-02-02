schema K8sFluxHelmOciReleaseWrapper:
    _name: str
    _helmReleaseName: str
    _helmReleaseNamespace: str
    _helmOciRepositoryWrapper: K8sFluxOciRepositoryWrapper
    _helmReleaseWrapperDependencies: [K8sFluxHelmReleaseWrapper | K8sFluxHelmOciReleaseWrapper] = []
    _targetK8sProviderConfigWrapper: K8sProviderConfigWrapper
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

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
                namespace = _tenantNamespace
            }
            spec = {
                interval = "1m"
                timeout = "5m"
                spec = {
                    chartRef = {
                        kind = "OCIRepository"
                        name = _helmOciRepositoryWrapper.managedResource.metadata.name
                        namespace = _tenantNamespace
                    }
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
                        name = _targetK8sProviderConfigWrapper.managedResource.spec.credentials.secretRef.name
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
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${_targetK8sProviderConfigWrapper.managedResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${_targetK8sProviderConfigWrapper.managedResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = _targetK8sProviderConfigWrapper.managedResource.apiVersion
        spec.of.kind = _targetK8sProviderConfigWrapper.managedResource.kind
        spec.of.resourceRef.name = _targetK8sProviderConfigWrapper.managedResource.metadata.name
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

