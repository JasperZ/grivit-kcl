schema K8sObjectRoleWrapper:
    _clusterName: str
    _name: str
    _projectNamespace: str
    _roleName: str
    _roleNamespace: str
    _roleRules: [any]
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "rbac.authorization.k8s.io/v1"
            kind = "Role"
            metadata.name = _roleName
            metadata.namespace = _roleNamespace
            rules = _roleRules
        }
        spec.providerConfigRef.name = k8sProviderConfigName(_projectNamespace, _clusterName)
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

