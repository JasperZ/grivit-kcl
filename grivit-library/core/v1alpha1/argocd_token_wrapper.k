import base64

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
        spec.writeConnectionSecretToRef.name = _resourceName
        spec.writeConnectionSecretToRef.namespace = _projectName
        spec.publishConnectionDetailsTo.name = _projectName + "1234abcd"
    }
    usages: [Usage] = []

    getToken: (any) -> str = lambda observedComposedResources: any -> str {
        _token: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _token = str(observedComposedResources[managedResource.metadata.name].ConnectionDetails?.token)

        _token
    }