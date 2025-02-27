schema KcRealmWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectNamespace: str
    _realmId: str

    managedResource: ManagedResource {
        apiVersion = "realm.keycloak.crossplane.io/v1alpha1"
        kind = "Realm"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            keycloakInstanceName = _instanceName
            keycloakInstanceOwnerProjectName = _instanceOwnerProjectName
            keycloakRealmId = _realmId
            projectName = _projectNamespace
        }
        metadata.name = _name
        spec.forProvider.enabled = True
        spec.forProvider.realm = _realmId
        spec.providerConfigRef.name = kcProviderConfigSecretName(_projectNamespace, _instanceOwnerProjectName, _instanceName, "master")
    }
    usages: [Usage] = []

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _id: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _id = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _id
    }

