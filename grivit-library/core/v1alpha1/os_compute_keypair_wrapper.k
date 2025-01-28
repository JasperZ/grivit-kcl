schema OsComputeKeypairWrapper:
    _name: str
    _targetOsProviderConfigName: str

    managedResource: ManagedResource {
        apiVersion = "compute.openstack.crossplane.io/v1alpha1"
        kind = "KeypairV2"
        metadata.name = _name
        spec.forProvider.name = _name
        spec.providerConfigRef.name = _targetOsProviderConfigName
    }
    usages: [Usage] = []

