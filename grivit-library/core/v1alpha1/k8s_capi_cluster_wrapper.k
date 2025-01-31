schema K8sCapiClusterWrapper:
    _name: str
    _controlPlaneK8sProviderConfigName: str
    _capiControlPlaneWrapper: K8sCapiKubeadmControlPlaneWrapper | K8sCapiK0smotronControlPlaneWrapper
    _capiInfrastructureWrapper: K8sCapiOsClusterWrapper
    _tenantNamespace: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "cluster.x-k8s.io/v1beta1"
            kind = "Cluster"
            metadata.name = _name
            metadata.namespace = _tenantNamespace
            spec = {
                clusterNetwork.pods.cidrBlocks = ["192.168.0.0/16"]
                clusterNetwork.serviceDomain = "cluster.local"
                controlPlaneRef = {
                    apiVersion = _capiControlPlaneWrapper.managedResource.spec.forProvider.manifest.apiVersion
                    kind = _capiControlPlaneWrapper.managedResource.spec.forProvider.manifest.kind
                    name = _capiControlPlaneWrapper.managedResource.spec.forProvider.manifest.metadata.name
                }
                infrastructureRef = {
                    apiVersion = _capiInfrastructureWrapper.managedResource.spec.forProvider.manifest.apiVersion
                    kind = _capiInfrastructureWrapper.managedResource.spec.forProvider.manifest.kind
                    name = _capiInfrastructureWrapper.managedResource.spec.forProvider.manifest.metadata.name
                }
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = [Usage {
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

