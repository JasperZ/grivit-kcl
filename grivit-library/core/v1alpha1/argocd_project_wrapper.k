schema ArgoCdProjectWrapper:
    _argoCdInstance: ArgoCdInstance
    _argoCdProjectAdminsGroupName: str
    _argoCdProjectDestinations: [any] = []
    _argoCdProjectViewersGroupName: str
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
            destinations = _argoCdProjectDestinations
            roles = [
                {
                    description = "Project admin"
                    groups = [_argoCdProjectAdminsGroupName]
                    name = "admins"
                    # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                    policies = [
                        "p, proj:${_resourceName}:admins, applications, *, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:admins, clusters, *, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:admins, repositories, *, ${_resourceName}/*, allow"
                    ]
                }
                {
                    description = "Project viewer"
                    groups = [_argoCdProjectViewersGroupName]
                    name = "viewers"
                    # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                    policies = [
                        "p, proj:${_resourceName}:viewers, applications, get, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:viewers, clusters, get, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:viewers, repositories, get, ${_resourceName}/*, allow"
                    ]
                }
            ]
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstanceOverride)
    }
    usages: [Usage] = []

