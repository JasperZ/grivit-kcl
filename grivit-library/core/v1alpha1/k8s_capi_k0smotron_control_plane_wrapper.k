schema K8sCapiK0smotronControlPlaneWrapper:
    _name: str

    _k8sVersion: str
    _controlPlaneK8sProviderConfigName: str
    _replicas: int
    _tenantNamespace: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "controlplane.cluster.x-k8s.io/v1beta1"
            kind = "K0smotronControlPlane"
            metadata.name = _name
            metadata.namespace = _tenantNamespace
            spec = {
                version = _k8sVersion
                persistence = {
                    type = "pvc"
                    persistentVolumeClaim = {
                        spec = {
                            accessModes = ["ReadWriteOnce"]
                            volumeMode = "Filesystem"
                            resources = {
                                requests = {
                                    storage = "8Gi"
                                }
                            }
                        }
                    }
                    service = {
                        type = "LoadBalancer"
                        apiPort = 6443
                        konnectivityPort = 8132
                    }
                }
                replicas = _replicas
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = []

    getKubernetesVersion: (any) -> str = lambda observedComposedResources: any -> str {
        _kubernetesVersion: str = _k8sVersion
        if managedResource.metadata.name in observedComposedResources:
            _kubernetesVersion = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.manifest?.status?.version or _k8sVersion)

        _kubernetesVersion
    }

