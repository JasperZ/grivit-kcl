import base64

schema OsIdentityApplicationCredentialWrapper:
    _name: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ApplicationCredentialV3"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.name = _name
        spec.forProvider.roles = ["admin"]
        spec.providerConfigRef.name = "${_projectNamespace}-os"
        spec.writeConnectionSecretToRef.name = _name + "-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
    }
    usages: [Usage] = []

    getApplicationCredentialId: (any) -> str = lambda observedComposedResources: any -> str {
        _applicationCredentialId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _applicationCredentialId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _applicationCredentialId
    }

    getApplicationCredentialSecret: (any) -> str = lambda observedComposedResources: any -> str {
        _applicationCredentialSecret: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _applicationCredentialSecret = base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails["attribute.secret"] or base64.encode("dummy"))

        _applicationCredentialSecret
    }

