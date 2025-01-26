import api.cp.core.v1 as cpCore

schema KcRealmWrapper:
    _controlPlaneKcProviderConfigName: str
    _name: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "realm.keycloak.crossplane.io/v1alpha1"
        kind = "Realm"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.enabled = True
        spec.forProvider.realm = _name
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [cpCore.Usage] = []

