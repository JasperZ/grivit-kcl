schema ArgoCdTokenWrapper:
    _argoCdInstance: ArgoCdInstance
    _argoCdTokenDescription: str
    _argoCdTokenId: str
    _argoCdTokenProject: str
    _argoCdTokenRole: str
    _projectName: str
    _resourceName: str

    _argoCdInstanceOverride: ArgoCdInstance {
        domain = _argoCdInstance.domain
        name = _argoCdInstance.name
        ownerProjectName = _argoCdInstance.ownerProjectName
        projectName = "instance"
    }

    managedResource: ManagedResource {
        apiVersion = "projects.argocd.crossplane.io/v1alpha1"
        kind = "Token"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            description = _argoCdTokenDescription
            id = _argoCdTokenId
            project = _argoCdTokenProject
            role = _argoCdTokenRole
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstanceOverride)
    }
    usages: [Usage] = []

