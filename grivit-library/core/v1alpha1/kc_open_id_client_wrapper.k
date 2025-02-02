import base64

schema KcOpenIdClientWrapper:
    _targetKcProviderConfigName: str
    _tenantNamespace: str
    _clientId: str
    _name: str
    _realmId: str
    _redirectUri: str
    _url: str

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "Client"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.accessType = "CONFIDENTIAL"
        spec.forProvider.adminUrl = _url
        spec.forProvider.clientId = _clientId
        spec.forProvider.directAccessGrantsEnabled = True
        spec.forProvider.name = _clientId
        spec.forProvider.realmId = _realmId
        spec.forProvider.rootUrl = _url
        spec.forProvider.standardFlowEnabled = True
        spec.forProvider.validPostLogoutRedirectUris = [_url]
        spec.forProvider.validRedirectUris = [_redirectUri]
        spec.forProvider.webOrigins = [_url]
        spec.writeConnectionSecretToRef.name = "${_name}-conn"
        spec.writeConnectionSecretToRef.namespace = _tenantNamespace
        spec.providerConfigRef.name = _targetKcProviderConfigName
    }
    usages: [Usage] = []

    getClientId: (any) -> str = lambda observedComposedResources: any -> str {
        _clientId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _clientId
    }

    getClientSecret: (any) -> str = lambda observedComposedResources: any -> str {
        _clientSecret: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientSecret = base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails["attribute.client_secret"])

        _clientSecret
    }

