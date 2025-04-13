schema OsIdentityProjectWrapper:
    _projectName: str
    _projectNamespace: str
    _resourceName: str

    managedResource: ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ProjectV3"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider.description = "Project '${_projectName}' manged by Crossplane"
        spec.forProvider.name = _projectName
        spec.providerConfigRef.name = osProviderConfigName(_projectNamespace)
    }
    usages: [Usage] = []

    getProjectId: (any) -> str = lambda observedComposedResources: any -> str {
        _projectId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _projectId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _projectId
    }

