schema K8sCapiOsMachineTemplateWrapper:
    _controlPlaneK8sProviderConfigName: str
    _flavor: str
    _imageName: str
    _keypairName: str
    _name: str
    _rootVolumeSize: int
    _tenantNamespace: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec.forProvider.manifest = {
            apiVersion = "infrastructure.cluster.x-k8s.io/v1beta1"
            kind = "OpenStackMachineTemplate"
            metadata.name = _name
            metadata.namespace = _tenantNamespace
            spec.template.spec = {
                flavor = _flavor
                image = {
                    "filter" = {
                        name = _imageName
                    }
                }
                rootVolume.sizeGiB = _rootVolumeSize
                sshKeyName = _keypairName
            }
        }
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

