schema OsIdentityProjectWrapper:
    _controlPlaneOsProviderConfigName: str
    _projectName: str

    managedResource: ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ProjectV3"
        metadata.name = _projectName
        spec.forProvider.description = "Project '${_projectName}' manged by Crossplane"
        spec.forProvider.name = _projectName
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [Usage] = []

    getProjectId: (any) -> str = lambda observedCompositeResource: any -> str {
        _projectId: str = ""
        if managedResource.metadata.name in observedCompositeResource:
            _projectId = str(observedCompositeResource[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _projectId
    }

