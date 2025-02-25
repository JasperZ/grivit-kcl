schema ArgoCdProjectWrapper:
    _instanceName: str
    _projectName: str
    _projectNamespace: str

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
                    groups = [""]
                    name = "admin"
                    policies = [
                        "p, proj:${_resourceName}:admin, *, *, *, allow"
                    ]
                }
                {
                    description = "Project viewer"
                    groups = [""]
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

