schema TfWorkspaceWrapperVars:
    name: str
    value: str | int | bool

schema TfWorkspaceWrapper:
    _moduleInlineCode: str
    _name: str
    _targetTfProviderConfigName: str
    _tenantNamespace: str
    _vars: [TfWorkspaceWrapperVars] = []

    managedResource: ManagedResource {
        apiVersion = "tf.upbound.io/v1beta1"
        kind = "Workspace"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.module = _moduleInlineCode
        spec.forProvider.source = "Inline"
        spec.providerConfigRef.name = _targetTfProviderConfigName
        spec.writeConnectionSecretToRef.name = "${_name}-conn"
        spec.writeConnectionSecretToRef.namespace = _tenantNamespace
    }
    usages: [Usage] = []

    getOutput: (any, str) -> str = lambda observedComposedResources: any, outputName: str -> str {
        _outputValue: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _outputValue = base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails[outputName] or base64.encode("dummy"))

        _outputValue
    }

