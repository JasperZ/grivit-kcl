schema KcGroupWrapper:
    _keycloakGroupName: str
    _keycloakInstance: KeycloakInstance
    _projectName: str
    _resourceName: str

    managedResource: ManagedResource {
        apiVersion = "group.keycloak.crossplane.io/v1alpha1"
        kind = "Group"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        metadata.labels = {
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-roject" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectName
        }
        spec.forProvider.name = _keycloakGroupName
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstance)
    }
    usages: [Usage] = []

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _atProviderId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _atProviderId
    }

