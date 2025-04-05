import crypto
import core.v1alpha1 as core

schema KeycloakProjectIntegration:
    _claimName: str
    _claimNamespace: str
    _keycloakInstance: core.KeycloakInstance
    _observedComposedResources: any
    _targetProjectName: str

    _keycloakInstanceTargetRealm: core.KeycloakInstance {
        domain = _keycloakInstance.domain
        name = _keycloakInstance.name
        ownerProjectName = _keycloakInstance.ownerProjectName
        realmId = _targetProjectName
    }

    _managedResourcePrefix = crypto.md5("${_claimNamespace}-${_claimName}-keycloak-${_keycloakInstanceTargetRealm.ownerProjectName}-${_keycloakInstanceTargetRealm.name}") + "-" + _keycloakInstanceTargetRealm.realmId + "-"

    realm: core.KcRealmWrapper {
        _keycloakInstance = _keycloakInstance
        _keycloakRealmId = _keycloakInstanceTargetRealm.realmId
        _name = "${_managedResourcePrefix}realm"
        _projectName = _claimNamespace
    }

    adminGroup: core.KcGroupWrapper {
        _keycloakGroupName = "admin"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}admin-group"
    }

    viewerGroup: core.KcGroupWrapper {
        _keycloakGroupName = "viewer"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}viewer-group"
    }

    crossplaneClient: core.KcOpenIdClientKcXpProviderWrapper {
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
    }

    realmManagementClientObserve: core.KcOpenIdClientWrapper {
        _clientId = "realm-management"
        _description = ""
        _keycloakInstance = _keycloakInstance
        _name = "${_managedResourcePrefix}realm-management"
        _projectNamespace = _claimNamespace
        _url = ""
        _validRedirectUris = []
        
        managedResource.spec.forProvider = {
            realmId = realm.managedResource.spec.forProvider.realm
            clientId = "realm-management"
        }
        managedResource.spec.managementPolicies = ["Observe"]
    }

    crossplaneClientRealmAdminRole: core.KcOpenIdClientServiceAccountRole {
        _clientId = realmManagementClientObserve.getAtProviderId(_observedComposedResources)
        _keycloakInstance = _keycloakInstance
        _name = "${_managedResourcePrefix}crossplane-client-realm-admin"
        _projectNamespace = _claimNamespace
        _roleName = "realm-admin"
        _serviceAccountUserId = crossplaneClient.getServiceAccountUserId(_observedComposedResources)
        _uses = [
            realmManagementClientObserve.managedResource
        ]
    }

    providerConfigCredentials: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = core.kcProviderConfigSecretName(_targetProjectName, _keycloakInstanceTargetRealm)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.kcProviderConfigSecretName(_targetProjectName, _keycloakInstanceTargetRealm)
        _stringData = {
            value = """\
{
  "client_id": "${crossplaneClient.managedResource.spec.forProvider.clientId}",
  "client_secret": "${crossplaneClient.getClientSecret(_observedComposedResources)}",
  "url": "https://${_keycloakInstance.domain}",
  "base_path": "/",
  "realm": "${_keycloakInstanceTargetRealm.realmId}"
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
        _keycloakInstance = _keycloakInstanceTargetRealm
        _projectName = _targetProjectName
        _uses = [
            providerConfigCredentials.managedResource
        ]
    }

    managedResources: [core.ManagedResource | core.KcProviderConfig | core.TfProviderConfig] = [
        realm.managedResource
        adminGroup.managedResource
        viewerGroup.managedResource
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
        crossplaneClient.usages
        realmManagementClientObserve.usages
        crossplaneClientRealmAdminRole.usages
        providerConfigCredentials.usages
        providerConfig.usages
    ], [])

