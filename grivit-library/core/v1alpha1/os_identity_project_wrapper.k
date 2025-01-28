schema OsIdentityProjectWrapper:
    _controlPlaneOsProviderConfigName: str
    _name: str
    _projectName: str

    managedResource: ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ProjectV3"
        metadata.name = _projectName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.description = "Project '${_projectName}' manged by Crossplane"
        spec.forProvider.name = _projectName
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [Usage] = []

    getProjectId: (any) -> str = lambda observedComposedResources: any -> str {
        _projectId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _projectId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _projectId
    }

