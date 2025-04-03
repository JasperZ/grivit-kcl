import core.v1alpha1 as core
import core.v1alpha1.argocd_utils as argoCdUtils

schema ArgoCdProjectIntegration:
    _argoCdDomain: str
    _argoCdInstanceName: str
    _argoCdInstanceOwnerProjectName: str
    _argoCdProjectName: str
    _claimNamespace: str
    _keycloakDomain: str
    _keycloakInstanceName: str
    _keycloakInstanceOwnerProjectName: str
    _keycloakRealmId: str
    _observedComposedResources: any
    _targetProjectName: str

    providerConfigKcClient: core.KcOpenIdClientArgoCdXpProviderWrapper {
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _projectName = _claimNamespace
        _realmId = _keycloakRealmId
    }
    providerConfigKcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-client-default-scopes"
        _projectName = _claimNamespace
        _realmId = _keycloakRealmId
        _uses = [
            providerConfigKcClient.managedResource
        ]
    }
    kcArgoCdAdminsGroup: core.KcGroupArgoCdWrapper {
        _groupType = "admins"
        _instanceName = _argoCdInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _projectName = _claimNamespace
        _realmId = _keycloakRealmId
        _uses = [
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    kcArgoCdViewersGroup: core.KcGroupArgoCdWrapper {
        _groupType = "viewers"
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _projectName = _claimNamespace
        _realmId = _keycloakRealmId
        _uses = [
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _groupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _projectName = _claimNamespace
        _realmId = _keycloakRealmId
        _userId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    # GroupMembershipProtocolMapper currently working with clientScopeId
    groupClientScope: core.KcOpenIdClientScopeWrapper {
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-group-client-scope"
        _projectNamespace = _claimNamespace
        _realmId = _keycloakRealmId
        _scopeName = "groups"
    }
    groupsMapper: core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-groups-mapper"
        _projectNamespace = _claimNamespace
        _realmId = _keycloakRealmId
        
        managedResource.spec.forProvider = {
            addToAccessToken = True
            claimName = "groups"
            clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
            name = "groups"
            realmId = _keycloakRealmId
        }
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _clientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _clientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _domain = _keycloakDomain
        _name = "${argoCdUtils.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceOwnerProjectName, _argoCdInstanceName, _argoCdProjectName)}-token"
        _realmId = _keycloakRealmId
        _projectNamespace = _claimNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = argoCdUtils.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceOwnerProjectName, _argoCdInstanceName, _argoCdProjectName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = argoCdUtils.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceOwnerProjectName, _argoCdInstanceName, _argoCdProjectName)
        _stringData = {
            value = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
        }
        _uses = [
            providerConfigHttpJwtToken.managedResource
        ]
    }
    providerConfig: core.ArgoCdProviderConfigWrapper {
        _argoCdDomain = _argoCdDomain
        _argoCdProjectName = _argoCdProjectName
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectName = _targetProjectName
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    argoCdProject: core.ArgoCdProjectWrapper {
        _adminGroupName = kcArgoCdAdminsGroup.managedResource.spec.forProvider.name
        _instanceName = _argoCdInstanceName
        _instanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _projectName = _argoCdProjectName
        _projectNamespace = _claimNamespace
        _viewerGroupName = kcArgoCdViewersGroup.managedResource.spec.forProvider.name
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdAdminsGroup.managedResource
        kcArgoCdViewersGroup.managedResource
        providerConfigKcClient.managedResource
        providerConfigKcClientDefaultScopes.managedResource
        kcUserGroupsWrapper.managedResource
        groupClientScope.managedResource
        groupsMapper.managedResource
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
        groupClientScope.usages
        groupsMapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        argoCdProject.usages
    ], [])

