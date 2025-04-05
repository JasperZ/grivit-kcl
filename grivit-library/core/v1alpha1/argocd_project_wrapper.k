schema ArgoCdProjectWrapper:
    _adminGroupName: str
    _instanceName: str
    _instanceOwnerProjectName: str
    _projectName: str
    _projectNamespace: str
    _viewerGroupName: str

    _resourceName: str = "${_projectNamespace}-argocd-${_instanceOwnerProjectName}-${_instanceName}-${_projectName}-project"

    managedResource: ManagedResource {
        apiVersion = "projects.argocd.crossplane.io/v1alpha1"
        kind = "Project"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            roles = [
                {
                    description = "Project admin"
                    groups = [_adminGroupName]
                    name = "admin"
                    # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                    policies = [
                        "p, proj:${_resourceName}:admin, applications, *, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:admin, clusters, *, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:admin, repositories, *, ${_resourceName}/*, allow"
                    ]
                }
                {
                    description = "Project viewer"
                    groups = [_viewerGroupName]
                    name = "viewer"
                    # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                    policies = [
                        "p, proj:${_resourceName}:viewer, applications, get, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:viewer, clusters, get, ${_resourceName}/*, allow"
                        "p, proj:${_resourceName}:viewer, repositories, get, ${_resourceName}/*, allow"
                    ]
                }
            ]
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectNamespace, _instanceOwnerProjectName, _instanceName, "instance")
    }
    usages: [Usage] = []

