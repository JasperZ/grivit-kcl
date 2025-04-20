schema ArgoCdProjectWrapper:
    _argoCdInstance: ArgoCdInstance
    _argoCdProjectDescription: str = ""
    _argoCdProjectDestinations: [any] = []
    _argoCdProjectRoles: [any] = []
    _argoCdProjectClusterResourceWhitelist: [any] = []
    _argoCdProjectSourceNamespaces: [str] = []
    _argoCdProjectSourceRepos: [str] = []
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
        kind = "Project"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            clusterResourceWhitelist= _argoCdProjectClusterResourceWhitelist
            description = _argoCdProjectDescription
            destinations = _argoCdProjectDestinations
            roles = _argoCdProjectRoles
            sourceNamespaces = _argoCdProjectSourceNamespaces
            sourceRepos = _argoCdProjectSourceRepos
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstanceOverride)
    }
    usages: [Usage] = []

