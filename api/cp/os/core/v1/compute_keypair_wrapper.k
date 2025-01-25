import api.cp.core.v1 as cpCore

schema ComputeKeypairWrapper:
    _name: str

    _targetOsProviderConfigName: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "compute.openstack.crossplane.io/v1alpha1"
        kind = "KeypairV2"
        metadata.name = _name
        spec.forProvider.name = _name
        spec.providerConfigRef.name = _targetOsProviderConfigName
    }
    usages: [cpCore.Usage] = []

