schema KcRealmWrapper:
    _keycloakInstance: KeycloakInstance
    _keycloakRealmId: str
    _name: str
    _projectName: str

    managedResource: ManagedResource {
        apiVersion = "realm.keycloak.crossplane.io/v1alpha1"
        kind = "Realm"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            keycloakInstanceName = _keycloakInstance.name
            keycloakInstanceOwnerProjectName = _keycloakInstance.ownerProjectName
            keycloakRealmId = _keycloakRealmId
            projectName = _projectName
        }
        metadata.name = _name
        spec.forProvider.enabled = True
        spec.forProvider.realm = _keycloakRealmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstance)
    }
    usages: [Usage] = []

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _id: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _id = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _id
    }

