import core.v1alpha1 as core

schema KcStage:
    _controlPlaneK8sProviderConfigName: str
    _name: str
    _observedComposedResources: any
    _realmName: str
    _targetKcDomain: str
    _targetKcProviderConfigWrapper: core.KcProviderConfigWrapper
    _tenantNamespace: str

    realm = core.KcRealmWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _name = "${_name}-realm"
        _realmName = _realmName
    }

    adminGroup = core.KcGroupWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _groupName = "admin"
        _name = "${_name}-admin-group"
        _realmId = _realmName
    }

    viewerGroup = core.KcGroupWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _groupName = "viewer"
        _name = "${_name}-viewer-group"
        _realmId = _realmName
    }

    groupClientScope = core.KcOpenIdClientScopeWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _name = "${_name}-group-client-scope"
        _realmId = _realmName
        _scopeName = "groups"
    }

    groupsMapper = core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _name = "${_name}-groups-mapper"
        _realmId = _realmName
    }

    crossplaneClient: core.KcOpenIdClientWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
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
  "url": "https://${_targetKcDomain}",
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

