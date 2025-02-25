schema ArgoCdProject:
    _argoCdDomain: str
    _argoCdInstanceName: str
    _kcDomain: str
    _kcInstanceName: str
    _kcRealmId: str
    _observedComposedResources: any
    _projectName: str
    _projectNamespace: str

    providerConfigKcClient: core.KcOpenIdClientArgoCdXpProviderWrapper {
        _instanceName = _kcInstanceName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
    }
    providerConfigKcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
        _instanceName = _kcInstanceName
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-client-default-scopes"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            providerConfigKcClient.managedResource
        ]
    }
    kcArgoCdAdminsGroup = core.KcGroupArgoCdWrapper {
        _groupType = "admins"
        _instanceName = _argoCdInstanceName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    kcArgoCdViewersGroup = core.KcGroupArgoCdWrapper {
        _groupType = "viewers"
        _instanceName = _kcInstanceName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _groupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _instanceName = _kcInstanceName
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _userId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _clientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _clientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _domain = _kcDomain
        _name = "${_projectNamespace}-argocd-${_argoCdInstanceName}-${_projectName}-token"
        _realmId = _kcRealmId
        _projectNamespace = _projectNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_projectNamespace}-argocd-${_argoCdInstanceName}-${_projectName}-provider"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "${_projectNamespace}-argocd-${_argoCdInstanceName}-${_projectName}-provider"
        _stringData = {
            value = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
        }
        _uses = [
            providerConfigHttpJwtToken.managedResource
        ]
    }
    providerConfig: core.ArgoCdProviderConfigWrapper {
        _name = "${_projectNamespace}-argocd-${_argoCdInstanceName}-${_projectName}"
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _domain = _argoCdDomain
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    argoCdProject: core.ArgoCdProjectWrapper {
        _adminGroupName = kcArgoCdAdminsGroup.managedResource.spec.forProvider.name
        _instanceName = _argoCdInstanceName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _viewerGroupName = kcArgoCdViewersGroup.managedResource.spec.forProvider.name
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdAdminsGroup.managedResource
        kcArgoCdViewersGroup.managedResource
        providerConfigKcClient.managedResource
        providerConfigKcClientDefaultScopes.managedResource
        kcUserGroupsWrapper.managedResource
        providerConfigHttpJwtToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        argoCdProject.managedResource
    ]
    usages: [core.Usage] = sum([
        kcArgoCdAdminsGroup.usages
        kcArgoCdViewersGroup.usages
        providerConfigKcClient.usages
        providerConfigKcClientDefaultScopes.usages
        kcUserGroupsWrapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        argoCdProject.usages
    ], [])

