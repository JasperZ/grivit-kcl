import base64

schema TfWorkspaceWrapperVars:
    name: str
    value: str | int | bool

schema TfWorkspaceWrapper:
    _moduleInlineCode: str
    _name: str
    _targetTfProviderConfigName: str
    _tenantNamespace: str
    _uses: [ManagedResource] = []
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

    getOutput: (any, str) -> str = lambda observedComposedResources: any, outputName: str -> str {
        _outputValue: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _outputValue = base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails[outputName] or base64.encode("dummy"))

        _outputValue
    }

