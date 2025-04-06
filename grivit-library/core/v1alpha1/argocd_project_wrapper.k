schema ArgoCdProjectWrapper:
    _argoCdInstance: ArgoCdInstance
    _argoCdProjectAdminsGroupName: str
    _argoCdProjectName: str
    _argoCdProjectViewersGroupName: str
    _projectName: str
    _compositionResourceName: str

    _argoCdInstanceOverride: ArgoCdInstance {
        domain = _argoCdInstance.domain
        name = _argoCdInstance.name
        ownerProjectName = _argoCdInstance.ownerProjectName
        projectName = "instance"
    }

    managedResource: ManagedResource {
        apiVersion = "projects.argocd.crossplane.io/v1alpha1"
        kind = "Project"
        metadata.name = _argoCdProjectName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _compositionResourceName
        }
        spec.forProvider = {
            roles = [
                {
                    description = "Project admin"
                    groups = [_argoCdProjectAdminsGroupName]
                    name = "admins"
                    # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                    policies = [
                        "p, proj:${_argoCdProjectName}:admins, applications, *, ${_argoCdProjectName}/*, allow"
                        "p, proj:${_argoCdProjectName}:admins, clusters, *, ${_argoCdProjectName}/*, allow"
                        "p, proj:${_argoCdProjectName}:admins, repositories, *, ${_argoCdProjectName}/*, allow"
                    ]
                }
                {
                    description = "Project viewer"
                    groups = [_argoCdProjectViewersGroupName]
                    name = "viewers"
                    # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                    policies = [
                        "p, proj:${_argoCdProjectName}:viewers, applications, get, ${_argoCdProjectName}/*, allow"
                        "p, proj:${_argoCdProjectName}:viewers, clusters, get, ${_argoCdProjectName}/*, allow"
                        "p, proj:${_argoCdProjectName}:viewers, repositories, get, ${_argoCdProjectName}/*, allow"
                    ]
                }
            ]
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstanceOverride)
    }
    usages: [Usage] = []

