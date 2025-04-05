import base64

schema KcOpenIdClientArgoCdXpProviderWrapper:
    _argoCdInstanceName: str
    _argoCdInstanceOwnerProjectName: str
    _argoCdProjectName: str
    _keycloakClientId: str
    _keycloakInstanceName: str
    _keycloakInstanceOwnerProjectName: str
    _keycloakRealmId: str
    _projectName: str
    _resourceName: str
    _uses: [ManagedResource] = []

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
        spec.forProvider.clientId = _keycloakClientId
        spec.forProvider.directAccessGrantsEnabled = False
        spec.forProvider.description = "managed by Crossplane"
        spec.forProvider.name = _keycloakClientId
        spec.forProvider.realmId = _keycloakRealmId
        spec.forProvider.serviceAccountsEnabled = True
        spec.forProvider.standardFlowEnabled = False
        spec.writeConnectionSecretToRef.name = "${_resourceName}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectName
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstanceOwnerProjectName, _keycloakInstanceName, _keycloakRealmId)
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_resourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_resourceName}-uses-${ofResource.metadata.name}"
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

