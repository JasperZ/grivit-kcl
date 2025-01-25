import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore

schema KustomizationWrapper:
    _name: str
    _path: str
    _k8sFluxGitRepository: GitRepositoryWrapper
    _kustomizationDependencies?: [KustomizationWrapper] = []
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _targetNamespace: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec.forProvider.manifest = {
            apiVersion = "kustomize.toolkit.fluxcd.io/v1"
            kind = "Kustomization"
            metadata = {
                name = _name
                namespace = _tenantNamespace
            }
            spec = {
                interval = "1m"
                sourceRef = {
                    kind = "GitRepository"
                    name = _k8sFluxGitRepository.managedResource.metadata.name
                    namespace = _tenantNamespace
                }
                path = _path
                prune = True
                targetNamespace = _targetNamespace
                timeout = "1m"
                kubeConfig = {
                    secretRef = {
                        name = _targetK8sProviderConfig.managedResource.spec.credentials.secretRef.name
                    }
                }
                dependsOn = [{
                    name = kustomization.managedResource.spec.forProvider.manifest.metadata.name
                } for kustomization in _kustomizationDependencies]
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [cpCore.Usage] = []

