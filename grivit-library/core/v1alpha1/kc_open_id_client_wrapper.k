import base64

schema KcOpenIdClientWrapper:
    _clientId: str
    _instanceName: str
    _name: str
    _projectNamespace: str
    _realmId: str
    _validRedirectUris: [str]
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
        spec.forProvider.validRedirectUris = _validRedirectUris
        spec.forProvider.webOrigins = [_url]
        spec.writeConnectionSecretToRef.name = "${_name}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = "${_projectNamespace}-${_instanceName}-${_realmId}-kc"
    }
    usages: [Usage] = []

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

