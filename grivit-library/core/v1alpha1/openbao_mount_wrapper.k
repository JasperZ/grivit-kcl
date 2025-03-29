schema OpenBaoMountWrapper:
    _mountType: "kv-v2"
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str
    _projectNamespace: str

    _subPathMapping: {str:str} = {
        "kv-v2": "kvv2"
    }

    managedResource: ManagedResource {
        apiVersion = "vault.vault.upbound.io/v1alpha1"
        kind = "Mount"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.path = "${_projectName}/${_subPathMapping[_mountType]}"
        spec.forProvider.type = _mountType
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = []

