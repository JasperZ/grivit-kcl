schema OsComputeKeypairWrapper:
    _name: str
    _targetOsProviderConfigName: str
    _tenantNamespace: str

    managedResource: ManagedResource {
        apiVersion = "compute.openstack.crossplane.io/v1alpha1"
        kind = "KeypairV2"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.name = _name
        spec.providerConfigRef.name = _targetOsProviderConfigName
        spec.writeConnectionSecretToRef.name = "${_name}-conn"
        spec.writeConnectionSecretToRef.namespace = _tenantNamespace
    }
    usages: [Usage] = []

