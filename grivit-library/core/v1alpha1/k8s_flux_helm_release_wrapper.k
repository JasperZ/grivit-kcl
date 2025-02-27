schema K8sFluxHelmReleaseWrapper:
    _clusterName: str
    _name: str
    _helmChartName: str
    _helmChartVersion: str
    _helmReleaseName: str
    _helmReleaseNamespace: str
    _helmRepositoryWrapper: K8sFluxHelmRepositoryWrapper
    _helmReleaseWrapperDependencies: [K8sFluxHelmReleaseWrapper | K8sFluxHelmOciReleaseWrapper] = []
    _projectNamespace: str
    _uses: [ManagedResource] = []

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
                chart = {
                    spec = {
                        chart = _helmChartName
                        version = _helmChartVersion
                        sourceRef = {
                            kind = "HelmRepository"
                            name = _helmRepositoryWrapper.managedResource.metadata.name
                            namespace = _projectNamespace
                        }
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
                        name = k8sProviderConfigSecretName(_projectNamespace, _clusterName)
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
        spec.providerConfigRef.name = k8sProviderConfigName(_projectNamespace, "ctrl")
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${_projectNamespace}-k8s-${_clusterName}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${_projectNamespace}-k8s-${_clusterName}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = "kubernetes.crossplane.io/v1alpha1"
        spec.of.kind = "ProviderConfig"
        spec.of.resourceRef.name = "${_projectNamespace}-k8s-${_clusterName}"
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
    } for k8sFluxHelmReleaseDependency in _helmReleaseWrapperDependencies] + [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

