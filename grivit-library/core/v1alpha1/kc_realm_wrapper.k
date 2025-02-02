import core.v1alpha1 as core

schema KcRealmWrapper:
    _targetKcProviderConfigWrapper: core.K8sProviderConfigWrapper
    _name: str
    _realmName: str

    managedResource: ManagedResource {
        apiVersion = "realm.keycloak.crossplane.io/v1alpha1"
        kind = "Realm"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.enabled = True
        spec.forProvider.realm = _realmName
        spec.providerConfigRef.name = _targetKcProviderConfigWrapper.managedResource.metadata.name
    }
    usages: [Usage] = []

