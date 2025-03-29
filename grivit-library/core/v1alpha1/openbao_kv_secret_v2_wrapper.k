schema OpenBaoKvSecretV2Wrapper:
    _name: str
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _projectName: str
    _projectNamespace: str
    _secretDataJsonSecretRefKey: str
    _secretDataJsonSecretRefName: str
    _secretDataJsonSecretRefNamespace: str
    _secretName: str

    managedResource: ManagedResource {
        apiVersion = "kv.vault.upbound.io/v1alpha1"
        kind = "SecretV2"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.mount = "${_projectName}/kvv2"
        spec.forProvider.name = _secretName
        spec.forProvider.dataJsonSecretRef.key = _secretDataJsonSecretRefKey
        spec.forProvider.dataJsonSecretRef.name = _secretDataJsonSecretRefName
        spec.forProvider.dataJsonSecretRef.namespace = _secretDataJsonSecretRefNamespace
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectNamespace, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
    }
    usages: [Usage] = []

