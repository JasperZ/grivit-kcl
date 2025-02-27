schema KcOpenIdClientScopeWrapper:
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectNamespace: str
    _realmId: str
    _scopeName: str

    managedResource: ManagedResource {
        apiVersion = "openidclient.keycloak.crossplane.io/v1alpha1"
        kind = "ClientScope"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        metadata.labels = {
            "keycloak-instance" = _instanceName
            "keycloak-instance-owner-roject" = _instanceOwnerProjectName
            "keycloak-realm-id" = _realmId
            "project" = _projectNamespace
        }
        spec.forProvider.includeInTokenScope = True
        spec.forProvider.name = _scopeName
        spec.forProvider.realmId = _realmId
        spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-${_realmId}"
    }
    usages: [Usage] = []

    getClientScopeId: (any) -> str = lambda observedComposedResources: any -> str {
        _clientScopeId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _clientScopeId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _clientScopeId
    }

