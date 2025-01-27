schema OsIdentityUserWrapper:
    _controlPlaneOsProviderConfigName: str
    _name: str
    _passwordSecret: K8sObjectSecretWrapper
    _passwordSecretKey: str
    _projectId: str
    _projectName: str
    _userName: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "UserV3"
        metadata.name = _name
        spec.forProvider.defaultProjectId = _projectId
        spec.forProvider.description = "User '${_userName}' managed and used by Crossplane to access the project '${_projectName}'"
        spec.forProvider.name = _userName
        spec.forProvider.passwordSecretRef = {
            key = _passwordSecretKey
            name = _passwordSecret.managedResource.spec.forProvider.manifest.metadata.name
            namespace = _passwordSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        }
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

    getUserId: (any) -> str = lambda observedCompositeResource: any -> str {
        _userId: str = ""
        if managedResource.metadata.name in observedCompositeResource:
            _userId = str(observedCompositeResource[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _userId
    }

