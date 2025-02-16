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
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    viewerGroup = core.KcGroupWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _groupName = "viewer"
        _name = "${_name}-viewer-group"
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    groupClientScope = core.KcOpenIdClientScopeWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _name = "${_name}-group-client-scope"
        _realmId = realm.managedResource.spec.forProvider.realm
        _scopeName = "groups"
    }

    groupsMapper = core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _name = "${_name}-groups-mapper"
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    crossplaneClient: core.KcOpenIdClientWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _tenantNamespace = _tenantNamespace
        _clientId = "${_name}-crossplane"
        _name = "${_name}-crossplane-client"
        _realmId = realm.managedResource.spec.forProvider.realm
        _redirectUri = ""
        _url = ""
        # override defaults
        managedResource.spec.forProvider = {
            accessType = "CONFIDENTIAL"
            clientId = "${_name}-crossplane"
            directAccessGrantsEnabled = False
            name = realm.managedResource.spec.forProvider.realm
            realmId = realm.managedResource.spec.forProvider.realm
            serviceAccountsEnabled = True
            standardFlowEnabled = False
        }
    }
    # START: Workaround to retrieve id of the realm-management client until crossplane keycloak is fixed
    kcTfProviderConfigWrapper: core.TfProviderConfigWrapper = {
        _name = "${_name}-kc-tfprovider-config"
        _configuration = """\
terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
      version = "5.1.1"
    }
  }

  backend "kubernetes" {
    secret_suffix     = "${_name}-kc-tfprovider-config-state"
    namespace         = "${_tenantNamespace}"
    in_cluster_config = true
  }
}

variable "client_id" {
    type = string
}

variable "username" {
    type = string
}

variable "password" {
    type = string
}

variable "url" {
    type = string
}

variable "base_path" {
    type = string
}

variable "realm" {
    type = string
}

provider "keycloak" {
    client_id = var.client_id
    username  = var.username
    password  = var.password
    url       = var.url
    base_path = var.base_path
    realm     = var.realm
}
"""
        _credentialsSecretName = _targetKcProviderConfigWrapper.managedResource.spec.credentials.secretRef.name
        _credentialsSecretNamespace = _targetKcProviderConfigWrapper.managedResource.spec.credentials.secretRef.namespace
        _uses = [crossplaneClient.managedResource]
    }

    realmManagementClientObserve: core.TfWorkspaceWrapper {
        _moduleInlineCode = """\
data "keycloak_openid_client" "realm_management" {
  realm_id  = "${realm.managedResource.spec.forProvider.realm}"
  client_id = "realm-management"
}

output "realm_management_client_id" {
  value = data.keycloak_openid_client.realm_management.id
}
"""
        _name = "${_name}-realm-management"
        _targetTfProviderConfigName = kcTfProviderConfigWrapper.managedResource.metadata.name
        _tenantNamespace = _tenantNamespace
    }
    # END: Workaround
    crossplaneClientRealmAdminRole: core.KcOpenIdClientServiceAccountRole {
        _clientId = realmManagementClientObserve.getOutput(_observedComposedResources, "realm_management_client_id")
        _name = "${_name}-crossplane-client-realm-admin"
        _realmId = realm.getId(_observedComposedResources)
        _roleName = "realm-admin"
        _serviceAccountUserId = crossplaneClient.getServiceAccountUserId(_observedComposedResources)
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _uses = [
            realmManagementClientObserve.managedResource
        ]
    }
    providerConfigCredentials: core.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _name = "${_name}-provider-config-credentials"
        _stringData = {
            value = """\
{
  "client_id": "${crossplaneClient.managedResource.spec.forProvider.clientId}",
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
            crossplaneClientRealmAdminRole.managedResource
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

    managedResources: [core.ManagedResource | core.KcProviderConfig | core.TfProviderConfig] = [
        realm.managedResource
        adminGroup.managedResource
        viewerGroup.managedResource
        groupClientScope.managedResource
        groupsMapper.managedResource
        crossplaneClient.managedResource
        kcTfProviderConfigWrapper.managedResource
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
        kcTfProviderConfigWrapper.usages
        realmManagementClientObserve.usages
        crossplaneClientRealmAdminRole.usages
        providerConfigCredentials.usages
        providerConfig.usages
    ], [])

