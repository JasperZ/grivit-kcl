import base64

schema KcOpenIdClientArgoCdWrapper:
    _argoCdDomain: str
    _instanceName: str
    _instanceOwnerProjectName: str
    _projectNamespace: str
    _realmId: str

    _clientId: str = "argocd-${_instanceName}-client"
    _baseUrl: str = "https://${_argoCdDomain}"
    _resourceName: str = "${_projectNamespace}-${_clientId}"

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "Client"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider.accessType = "CONFIDENTIAL"
        spec.forProvider.adminUrl = _baseUrl
        spec.forProvider.clientId = _clientId
        spec.forProvider.directAccessGrantsEnabled = True
        spec.forProvider.description = "ArgoCD client for instance '${_instanceName}' to authenticate users (managed by Crossplane)."
        spec.forProvider.name = _clientId
        spec.forProvider.realmId = _realmId
        spec.forProvider.rootUrl = _baseUrl
        spec.forProvider.standardFlowEnabled = True
        spec.forProvider.validPostLogoutRedirectUris = [_baseUrl]
        spec.forProvider.validRedirectUris = ["${_baseUrl}/auth/callback"]
        spec.forProvider.webOrigins = [_baseUrl]
        spec.writeConnectionSecretToRef.name = "${_resourceName}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-${_realmId}"
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

