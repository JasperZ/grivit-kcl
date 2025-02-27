import base64

schema KcOpenIdClientKcXpProviderWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _projectNamespace: str
    _realmId: str

    _clientId: str = "kc-${_instanceName}-${_realmId}-xp-provider"
    _resourceName: str = "${_projectNamespace}-${_clientId}"

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "Client"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        metadata.labels = {
            "keycloak-instance" = _instanceName
            "keycloak-instance-owner-roject" = _instanceOwnerProjectName
            "keycloak-realm-id" = _realmId
            "project" = _projectNamespace
        }
        spec.forProvider.accessType = "CONFIDENTIAL"
        spec.forProvider.clientId = _clientId
        spec.forProvider.directAccessGrantsEnabled = False
        spec.forProvider.description = "Crossplane Keycloak provider client for realm '${_realmId}' of instance '${_instanceName}' (managed by Crossplane)."
        spec.forProvider.name = _clientId
        spec.forProvider.realmId = _realmId
        spec.forProvider.serviceAccountsEnabled = True
        spec.forProvider.standardFlowEnabled = False
        spec.writeConnectionSecretToRef.name = "${_resourceName}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-master"
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

