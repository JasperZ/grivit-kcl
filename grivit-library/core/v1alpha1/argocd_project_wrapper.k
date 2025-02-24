schema ArgoCdProjectWrapper:
    _instanceName: str
    _name: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "projects.argocd.crossplane.io/v1alpha1"
        kind = "Project"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider = {}
        spec.providerConfigRef.name = "${_projectNamespace}-argocd-${_instanceName}-global"
    }
    usages: [Usage] = []

