schema OsComputeKeypairWrapper:
    _name: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "compute.openstack.crossplane.io/v1alpha1"
        kind = "KeypairV2"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.name = _name
        spec.providerConfigRef.name = osProviderConfigName(_projectNamespace)
        spec.writeConnectionSecretToRef.name = "${_name}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
    }
    usages: [Usage] = []

    check:
        len(managedResource.metadata.name) < 64
