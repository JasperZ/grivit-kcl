schema OpenBaoProviderConfigK8sCredentialsSecretWrapper:
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _openBaoJwtToken: str
    _openBaoProjectName: str
    _openBaoRole: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _resourceName: str = openBaoProviderConfigSecretName(_projectNamespace, _openBaoInstanceOwnerProjectName, _openBaoInstanceName, _openBaoProjectName)

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider.manifest = {
            apiVersion = "v1"
            kind = "Secret"
            metadata.name = _resourceName
            metadata.namespace = _projectNamespace
            type = "Opaque"
            stringData = {
                value = {
                    auth_login_jwt = {
                        jwt = _openBaoJwtToken
                        role = _openBaoRole
                    }
                }
            }
        }
        spec.providerConfigRef.name = k8sProviderConfigName(_projectNamespace, "ctrl")
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_resourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_resourceName}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

