schema OsIdentityApplicationCredentialWrapper:
    _name: str
    _tenantNamespace: str
    _targetOsProviderConfigName: str

    managedResource: ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ApplicationCredentialV3"
        metadata.name = _name
        spec.forProvider.name = _name
        spec.forProvider.roles = ["admin"]
        spec.providerConfigRef.name = _targetOsProviderConfigName
        spec.writeConnectionSecretToRef.name = _name + "-conn"
        spec.writeConnectionSecretToRef.namespace = _tenantNamespace
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

