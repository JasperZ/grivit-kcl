schema OpenBaoPolicyWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _policyName: str
    _policyDocument: str
    _projectName: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "vault.vault.upbound.io/v1alpha1"
        kind = "Backend"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.name = _policyName
        spec.forProvider.policy = _policyDocument
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _instanceName, _instanceOwnerProjectName, "admin")
    }
    usages: [Usage] = []

