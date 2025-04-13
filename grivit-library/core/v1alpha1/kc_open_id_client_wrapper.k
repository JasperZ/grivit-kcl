import base64

schema KcOpenIdClientWrapper:
    _clientId: str
    _description: str
    _keycloakInstance: KeycloakInstance
    _keycloakProviderConfig?: str
    _name: str
    _projectNamespace: str
    _url: str
    _validRedirectUris: [str]
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "Client"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-roject" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectNamespace
        }
        spec.forProvider.accessType = "CONFIDENTIAL"
        spec.forProvider.adminUrl = _url
        spec.forProvider.clientId = _clientId
        spec.forProvider.directAccessGrantsEnabled = True
        spec.forProvider.description = _description
        spec.forProvider.name = _clientId
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.forProvider.rootUrl = _url
        spec.forProvider.standardFlowEnabled = True
        spec.forProvider.validPostLogoutRedirectUris = [_url]
        spec.forProvider.validRedirectUris = _validRedirectUris
        spec.forProvider.webOrigins = [_url]
        spec.writeConnectionSecretToRef.name = "${_name}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = _keycloakProviderConfig if _keycloakProviderConfig else kcProviderConfigName(_projectNamespace, _keycloakInstance)
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
        _id: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _id = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _id
    }

    getClientSecret: (any) -> str = lambda observedComposedResources: any -> str {
        _clientSecret: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientSecret = base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails["attribute.client_secret"])

        _clientSecret
    }

    getServiceAccountUserId: (any) -> str = lambda observedComposedResources: any -> str {
        _serviceAccountUserId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _serviceAccountUserId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.serviceAccountUserId or "")

        _serviceAccountUserId
    }
