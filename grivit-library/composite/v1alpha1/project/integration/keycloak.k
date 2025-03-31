import core.v1alpha1 as core
import core.v1alpha1.kc_utils as kcUtils

schema Keycloak:
    _keycloakDomain: str
    _keycloakInstanceName: str
    _keycloakInstanceOwnerProjectName: str
    _keycloakRealmName: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    realm = core.KcRealmWrapper {
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-realm"
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmName
    }

    adminGroup = core.KcGroupWrapper {
        _groupName = "admin"
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-admin-group"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    viewerGroup = core.KcGroupWrapper {
        _groupName = "viewer"
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-viewer-group"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    groupClientScope = core.KcOpenIdClientScopeWrapper {
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-group-client-scope"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
        _scopeName = "groups"
    }

    groupsMapper = core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-groups-mapper"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
    }
    crossplaneClient: core.KcOpenIdClientKcXpProviderWrapper {
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
    }
    realmManagementClientObserve: core.KcOpenIdClientWrapper {
        _clientId = "realm-management"
        _description = ""
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-realm-management"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
        _url = ""
        _validRedirectUris = []
        
        managedResource.spec.forProvider = {
            realmId = realm.managedResource.spec.forProvider.realm
            clientId = "realm-management"
        }
        managedResource.spec.providerConfigRef.name = kcUtils.kcProviderConfigName(_projectNamespace, _keycloakInstanceOwnerProjectName, _instanceName, "master")
        managedResource.spec.managementPolicies = ["Observe"]
    }
    crossplaneClientRealmAdminRole: core.KcOpenIdClientServiceAccountRole {
        _clientId = realmManagementClientObserve.getAtProviderId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_name}-crossplane-client-realm-admin"
        _projectNamespace = _projectNamespace
        _realmId = realm.getAtProviderId(_observedComposedResources)
        _roleName = "realm-admin"
        _serviceAccountUserId = crossplaneClient.getServiceAccountUserId(_observedComposedResources)
        # Use provider for master realm to setup crossplane client
        managedResource.spec.providerConfigRef.name = kcUtils.kcProviderConfigName(_projectNamespace, _keycloakInstanceOwnerProjectName, _keycloakInstanceName, "master")
        _uses = [
            realmManagementClientObserve.managedResource
        ]
    }
    providerConfigCredentials: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = kcUtils.kcProviderConfigSecretName(_projectNamespace, _keycloakInstanceOwnerProjectName, _keycloakInstanceName, _keycloakRealmName)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = kcUtils.kcProviderConfigSecretName(_projectNamespace, _keycloakInstanceOwnerProjectName, _keycloakInstanceName, _keycloakRealmName)
        _stringData = {
            value = """\
{
  "client_id": "${crossplaneClient.managedResource.spec.forProvider.clientId}",
  "client_secret": "${crossplaneClient.getClientSecret(_observedComposedResources)}",
  "url": "https://${_keycloakDomain}",
  "base_path": "/",
  "realm": "${_keycloakRealmName}"
}
"""
        }
        _uses = [
            realm.managedResource
            crossplaneClient.managedResource
            crossplaneClientRealmAdminRole.managedResource
        ]
    }
    providerConfig: core.KcProviderConfigWrapper {
        _credentialsSecretName = providerConfigCredentials.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentials.managedResource.spec.forProvider.manifest.metadata.namespace
        _kcInstanceName = _keycloakInstanceName
        _kcInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _kcRealmId = _keycloakRealmName
        _projectNamespace = _projectNamespace
        _uses = [
            providerConfigCredentials.managedResource
        ]
    }
    managedResources: [core.ManagedResource | core.KcProviderConfig | core.TfProviderConfig] = [
        realm.managedResource
        adminGroup.managedResource
        viewerGroup.managedResource
        groupClientScope.managedResource
        groupsMapper.managedResource
        crossplaneClient.managedResource
        realmManagementClientObserve.managedResource
        crossplaneClientRealmAdminRole.managedResource
        providerConfigCredentials.managedResource
        providerConfig.managedResource
    ]

    usages: [core.Usage] = sum([
        realm.usages
        adminGroup.usages
        viewerGroup.usages
        groupClientScope.usages
        groupsMapper.usages
        crossplaneClient.usages
        realmManagementClientObserve.usages
        crossplaneClientRealmAdminRole.usages
        providerConfigCredentials.usages
        providerConfig.usages
    ], [])

