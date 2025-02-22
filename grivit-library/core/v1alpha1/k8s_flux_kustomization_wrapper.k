schema K8sFluxKustomizationWrapper:
    _clusterName: str
    _k8sFluxGitRepository: K8sFluxGitRepositoryWrapper
    _kustomizationDependencies?: [K8sFluxKustomizationWrapper] = []
    _name: str
    _path: str
    _projectNamespace: str
    _targetNamespace: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "kustomize.toolkit.fluxcd.io/v1"
            kind = "Kustomization"
            metadata = {
                name = _name
                namespace = _projectNamespace
            }
            spec = {
                interval = "1m"
                sourceRef = {
                    kind = "GitRepository"
                    name = _k8sFluxGitRepository.managedResource.metadata.name
                    namespace = _projectNamespace
                }
                path = _path
                prune = True
                targetNamespace = _targetNamespace
                timeout = "1m"
                kubeConfig = {
                    secretRef = {
                        name = "${_projectNamespace}-${_clusterName}-k8s-provider"
                    }
                }
                dependsOn = [{
                    name = kustomization.managedResource.spec.forProvider.manifest.metadata.name
                } for kustomization in _kustomizationDependencies]
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = "${_projectNamespace}-ctrl-k8s"
    }
    usages: [Usage] = []

