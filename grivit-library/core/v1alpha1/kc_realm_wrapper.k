schema KcRealmWrapper:
    _targetKcProviderConfigWrapper: KcProviderConfigWrapper
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

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _id: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _id = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _id
    }

