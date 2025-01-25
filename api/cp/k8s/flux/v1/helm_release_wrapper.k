import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore

schema HelmReleaseWrapper:
    _name: str
    _helmChartName: str
    _helmChartVersion: str
    _helmReleaseName: str
    _helmReleaseNamespace: str
    _helmRepositoryWrapper: HelmRepositoryWrapper
    _helmReleaseWrapperDependencies?: [HelmReleaseWrapper] = []
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
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
                chart = {
                    spec = {
                        chart = _helmChartName
                        version = _helmChartVersion
                        sourceRef = {
                            kind = "HelmRepository"
                            name = _helmRepositoryWrapper.managedResource.metadata.name
                            namespace = _tenantNamespace
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
                        name = _targetK8sProviderConfig.managedResource.spec.credentials.secretRef.name
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
    usages: [cpCore.Usage] = [cpCore.Usage {
        metadata.name = "${_name}-uses-${_targetK8sProviderConfig.managedResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = _targetK8sProviderConfig.managedResource.apiVersion
        spec.of.kind = _targetK8sProviderConfig.managedResource.kind
        spec.of.resourceRef.name = _targetK8sProviderConfig.managedResource.metadata.name
    }] + [cpCore.Usage {
        metadata.name = "${_name}-uses-${k8sFluxHelmReleaseDependency.managedResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = k8sFluxHelmReleaseDependency.managedResource.apiVersion
        spec.of.kind = k8sFluxHelmReleaseDependency.managedResource.kind
        spec.of.resourceRef.name = k8sFluxHelmReleaseDependency.managedResource.metadata.name
    } for k8sFluxHelmReleaseDependency in _helmReleaseWrapperDependencies]

