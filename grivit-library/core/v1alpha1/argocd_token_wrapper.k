schema ArgoCdTokenWrapper:
    _argoCdInstanceName: str
    _argoCdInstanceOwnerProjectName: str
    _managedResourceName: str
    _projectName: str
    _tokenDescription: str
    _tokenId: str
    _tokenProject: str
    _tokenRole: str

    managedResource: ManagedResource {
        apiVersion = "projects.argocd.crossplane.io/v1alpha1"
        kind = "Token"
        metadata.name = _managedResourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _managedResourceName
        }
        spec.forProvider = {
            description = _tokenDescription
            id = _tokenId
            project = _tokenProject
            role = _tokenRole
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstanceOwnerProjectName, _argoCdInstanceName, "admin")
    }
    usages: [Usage] = []

