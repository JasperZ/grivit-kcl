schema KcGroupWrapper:
    _keycloakGroupName: str
    _keycloakInstance: KeycloakInstance
    _keycloakProviderConfig?: str
    _projectName: str
    _resourceName: str
    _uses: [ManagedResource] = []

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
        spec.providerConfigRef.name = _keycloakProviderConfig if _keycloakProviderConfig else kcProviderConfigName(_projectName, _keycloakInstance)
    }
    usages: [Usage] = [Usage {
        metadata.name = "${managedResource.metadata.name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${managedResource.metadata.name}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _atProviderId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _atProviderId
    }

