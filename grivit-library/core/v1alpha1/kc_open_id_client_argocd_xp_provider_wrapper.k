import base64

schema KcOpenIdClientArgoCdXpProviderWrapper:
    _instanceName: str
    _projectName: str
    _projectNamespace: str
    _realmId: str
    _uses: [ManagedResource] = []

    _clientId: str = "argocd-${_instanceName}-${_projectName}-xp-provider"
    _resourceName: str = "${_projectNamespace}-${_clientId}"

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "Client"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider.accessType = "CONFIDENTIAL"
        spec.forProvider.clientId = _clientId
        spec.forProvider.directAccessGrantsEnabled = False
        spec.forProvider.description = "Crossplane ArgoCD provider client for project '${_projectName}' of instance '${_instanceName}' (managed by Crossplane)."
        spec.forProvider.name = _clientId
        spec.forProvider.realmId = _realmId
        spec.forProvider.serviceAccountsEnabled = True
        spec.forProvider.standardFlowEnabled = False
        spec.writeConnectionSecretToRef.name = "${_resourceName}-conn"
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceName}-${_realmId}"
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

