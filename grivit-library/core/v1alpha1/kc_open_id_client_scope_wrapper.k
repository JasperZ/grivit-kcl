schema KcOpenIdClientScopeWrapper:
    _keycloakInstance: KeycloakInstance
    _name: str
    _projectName: str
    _scopeName: str

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientScope"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-roject" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectName
        }
        spec.forProvider.includeInTokenScope = True
        spec.forProvider.name = _scopeName
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstance)
    }
    usages: [Usage] = []

    getClientScopeId: (any) -> str = lambda observedComposedResources: any -> str {
        _clientScopeId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientScopeId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _clientScopeId
    }

