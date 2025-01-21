schema KcOpenIdClient:
    _controlPlaneKcProviderConfigName: str
    _connectionSecretName: str
    _connectionSecretNamespace: str
    _clientId: str
    _name: str
    _realmId: str
    _redirectUri: str
    _url: str

    managedResource: CpManagedResource {
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
        spec.writeConnectionSecretToRef.name = _connectionSecretName
        spec.writeConnectionSecretToRef.namespace = _connectionSecretNamespace
        spec.providerConfigRef.name = _controlPlaneKcProviderConfigName
    }
    usages: [CpUsage] = []

