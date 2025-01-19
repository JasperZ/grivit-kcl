schema KcRealmWrapper:
    _controlPlaneKcProviderConfigName: str
    _name: str

    managedResource: CpManagedResource {
        apiVersion = "realm.keycloak.crossplane.io/v1alpha1"
        kind = "Realm"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.enabled = True
        spec.forProvider.realm = _name
        spec.forProvider.policy = _name
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [CpUsage] = []

