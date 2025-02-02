import core.v1alpha1 as core

schema KcStage:
    _controlPlaneK8sProviderConfigName: str
    _name: str
    _observedComposedResources: any
    _realmName: str
    _targetKcProviderConfigName: str
    _tenantNamespace: str

    realm = core.KcRealmWrapper {
        _targetKcProviderConfigName = _targetKcProviderConfigName
        _name = "${_name}-realm"
        _realmName = _realmName
    }

    adminGroup = core.KcGroupWrapper {
        _targetKcProviderConfigName = _targetKcProviderConfigName
        _groupName = "admin"
        _name = "${_name}-admin-group"
        _realmId = realm.managedResource.metadata.name
    }

    viewerGroup = core.KcGroupWrapper {
        _targetKcProviderConfigName = _targetKcProviderConfigName
        _groupName = "viewer"
        _name = "${_name}-viewer-group"
        _realmId = realm.managedResource.metadata.name
    }

    groupClientScope = core.KcOpenIdClientScopeWrapper {
        _targetKcProviderConfigName = _targetKcProviderConfigName
        _name = "${_name}-group-client-scope"
        _realmId = realm.managedResource.metadata.name
        _scopeName = "groups"
    }

    groupsMapper = core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _targetKcProviderConfigName = _targetKcProviderConfigName
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _name = "${_name}-groups-mapper"
        _realmId = realm.managedResource.metadata.name
    }

    crossplaneClient: core.KcOpenIdClientWrapper {
        _targetKcProviderConfigName = _targetKcProviderConfigName
        _tenantNamespace = _tenantNamespace
        _clientId = "${_name}-crossplane"
        _name = "${_name}-crossplane-client"
        _realmId = _realmName
        _redirectUri = ""
        _url = ""
    }
    providerConfigCredentials: core.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _name = "${_name}-provider-config-credentials"
        _stringData = {
            value = """\
{
  "client_id": "${crossplaneClient.getClientId(_observedComposedResources)}",
  "client_secret": "${crossplaneClient.getClientSecret(_observedComposedResources)}",
  "url": "https://keycloak.nonprod-test1.test.grivit.com",
  "base_path": "/",
  "realm": "${_realmName}"
}
"""
        }
        _targetNamespace = _tenantNamespace
        _uses = [
            realm.managedResource
            crossplaneClient.managedResource
        ]
    }
    providerConfig: core.KcProviderConfigWrapper {
        _name = "${_name}-kc-provider-config"
        _credentialsSecretName = providerConfigCredentials.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentials.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            providerConfigCredentials.managedResource
        ]
    }
    managedResources: [core.ManagedResource | core.KcProviderConfig] = [
        realm.managedResource
        adminGroup.managedResource
        viewerGroup.managedResource
        groupClientScope.managedResource
        groupsMapper.managedResource
        crossplaneClient.managedResource
        providerConfigCredentials.managedResource
        providerConfig.managedResource
    ]

    usages: [core.Usage] = realm.usages + adminGroup.usages + viewerGroup.usages + groupClientScope.usages + groupsMapper.usages + crossplaneClient.usages + providerConfigCredentials.usages + providerConfig.usages

