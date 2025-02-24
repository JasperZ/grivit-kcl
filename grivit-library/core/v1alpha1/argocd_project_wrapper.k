schema ArgoCdProjectWrapper:
    _instanceName: str
    _name: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "argoproj.io/v1alpha1"
        kind = "AppProject"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider = {}
        spec.providerConfigRef.name = "${_projectNamespace}-argocd-${_instanceName}-admin"
    }
    usages: [Usage] = []

