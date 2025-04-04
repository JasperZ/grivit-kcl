import base64

schema KcOpenIdClientArgoCdWrapper:
    _argoCdDomain: str
    _argoCdInstanceName: str
    _argoCdInstanceOwnerProjectName: str
    _argoCdProjectName: str
    _keycloakInstanceName: str
    _keycloakInstanceOwnerProjectName: str
    _keycloakRealmId: str
    _projectName: str

    _baseUrl: str = "https://${_argoCdDomain}"
    _clientId: str = "argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-client"
    _resourceName: str = "${_projectName}-${_clientId}"

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "Client"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        metadata.labels = {
            "argocd-instance" = _argoCdInstanceName
            "argocd-instance-owner-project" = _argoCdInstanceOwnerProjectName
            "argocd-project-name" = _argoCdProjectName
            "keycloak-instance" = _keycloakInstanceName
            "keycloak-instance-owner-project" = _keycloakInstanceOwnerProjectName
            "keycloak-realm-id" = _keycloakRealmId
            "project" = _projectName
        }
        spec.forProvider.accessType = "CONFIDENTIAL"
        spec.forProvider.adminUrl = _baseUrl
        spec.forProvider.clientId = _clientId
        spec.forProvider.directAccessGrantsEnabled = True
        spec.forProvider.description = "managed by Crossplane"
        spec.forProvider.name = _clientId
        spec.forProvider.realmId = _keycloakRealmId
        spec.forProvider.rootUrl = _baseUrl
        spec.forProvider.standardFlowEnabled = True
        spec.forProvider.validPostLogoutRedirectUris = [_baseUrl]
        spec.forProvider.validRedirectUris = ["${_baseUrl}/auth/callback"]
        spec.forProvider.webOrigins = [_baseUrl]
        spec.writeConnectionSecretToRef.name = "${_resourceName}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectName
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstanceOwnerProjectName, _keycloakInstanceName, _keycloakRealmId)
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

