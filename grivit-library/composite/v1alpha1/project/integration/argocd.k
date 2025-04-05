import crypto
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

    #_managedResourcePrefix = "${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-"
    _managedResourcePrefix = crypto.md5("${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}") + "-" + _argoCdProjectName + "-"

    providerConfigKcClient: core.KcOpenIdClientArgoCdXpProviderWrapper {
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName = _argoCdProjectName
        _keycloakInstanceName= _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId= _keycloakRealmId
        _projectName = _claimNamespace
    }
    kcArgoCdAdminsGroup: core.KcGroupArgoCdWrapper {
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName= _argoCdProjectName
        _groupType = "admins"
        _keycloakInstanceName = _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId = _keycloakRealmId
        _projectName = _claimNamespace
        _uses = []
    }
    kcArgoCdViewersGroup: core.KcGroupArgoCdWrapper {
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName= _argoCdProjectName
        _groupType = "viewers"
        _keycloakInstanceName = _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId = _keycloakRealmId
        _projectName = _claimNamespace
        _uses = []
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _keycloakInstanceName= _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId= _keycloakRealmId
        _keycloakUserId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _projectName = _claimNamespace
        _managedResourceName = "${_managedResourcePrefix}client"
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    # GroupMembershipProtocolMapper currently working with clientScopeId
    groupClientScope: core.KcOpenIdClientScopeWrapper {
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_managedResourcePrefix}group-client-scope"
        _projectNamespace = _claimNamespace
        _realmId = _keycloakRealmId
        _scopeName = "groups"
    }
    groupsMapper: core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_managedResourcePrefix}groups-mapper"
        _projectNamespace = _claimNamespace
        _realmId = _keycloakRealmId
        
        managedResource.spec.forProvider = {
            addToAccessToken = True
            claimName = "groups"
            clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
            fullPath = False
            name = "groups"
            realmId = _keycloakRealmId
        }
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _keycloakClientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _keycloakClientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _keycloakDomain = _keycloakDomain
        _keycloakRealmId = _keycloakRealmId
        _managedResourceName = "${argoCdUtils.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceOwnerProjectName, _argoCdInstanceName, _argoCdProjectName)}-token"
        _projectName = _claimNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
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
        _resourceName= "${_managedResourcePrefix}project"
        _viewerGroupName = kcArgoCdViewersGroup.managedResource.spec.forProvider.name
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdAdminsGroup.managedResource
        kcArgoCdViewersGroup.managedResource
        providerConfigKcClient.managedResource
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
        kcUserGroupsWrapper.usages
        groupClientScope.usages
        groupsMapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        argoCdProject.usages
    ], [])

