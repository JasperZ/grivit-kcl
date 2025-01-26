import api.cp.core.v1 as cpCore

schema KcGroupWrapper:
    _controlPlaneKcProviderConfigName: str
    _groupName: str
    _name: str
    _realmId: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "group.keycloak.crossplane.io/v1alpha1"
        kind = "Group"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.name = _groupName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [cpCore.Usage] = []

