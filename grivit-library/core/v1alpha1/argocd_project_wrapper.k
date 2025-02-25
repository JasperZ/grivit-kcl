schema ArgoCdProjectWrapper:
    _adminGroupName: str
    _instanceName: str
    _projectName: str
    _projectNamespace: str
    _viewerGroupName: str

    _resourceName: str = "${_projectNamespace}-argocd-${_instanceName}-${_projectName}-project"

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
                    policies = [
                        "p, proj:${_resourceName}:admin, *, *, *, allow"
                    ]
                }
                {
                    description = "Project viewer"
                    groups = [_viewerGroupName]
                    name = "viewer"
                    policies = [
                        "p, proj:${_resourceName}:viewer, *, get, *, allow"
                    ]
                }
            ]
        }
        spec.providerConfigRef.name = "${_projectNamespace}-argocd-${_instanceName}-admin"
    }
    usages: [Usage] = []

