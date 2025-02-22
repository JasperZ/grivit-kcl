import core.v1alpha1 as core

schema KcStage:
    _name: str
    _observedComposedResources: any
    _realmName: str
    _targetKcDomain: str
    _targetKcProviderConfigWrapper: core.KcProviderConfigWrapper
    _projectNamespace: str
    _instanceName: str

    realm = core.KcRealmWrapper {
        _instanceName = _instanceName
        _name = "${_name}-realm"
        _projectNamespace = _projectNamespace
        _realmName = _realmName
    }

    adminGroup = core.KcGroupWrapper {
        _groupName = "admin"
        _instanceName = _instanceName
        _name = "${_name}-admin-group"
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    viewerGroup = core.KcGroupWrapper {
        _groupName = "viewer"
        _instanceName = _instanceName
        _name = "${_name}-viewer-group"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    groupClientScope = core.KcOpenIdClientScopeWrapper {
        _instanceName = _instanceName
        _name = "${_name}-group-client-scope"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
        _scopeName = "groups"
    }

    groupsMapper = core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = groupClientScope.getClientScopeId(_observedComposedResources)
        _instanceName = _instanceName
        _name = "${_name}-groups-mapper"
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
    }

    crossplaneClient: core.KcOpenIdClientWrapper {
        _clientId = "${_name}-crossplane"
        _instanceName = _instanceName
        _name = "${_name}-crossplane-client"
        _projectNamespace = _projectNamespace
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
    namespace         = "${_projectNamespace}"
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
        _projectNamespace = _projectNamespace
        _providerConfigName = kcTfProviderConfigWrapper.managedResource.metadata.name
    }
    # END: Workaround
    crossplaneClientRealmAdminRole: core.KcOpenIdClientServiceAccountRole {
        _clientId = realmManagementClientObserve.getOutput(_observedComposedResources, "realm_management_client_id")
        _instanceName = _instanceName
        _name = "${_name}-crossplane-client-realm-admin"
        _projectNamespace = _projectNamespace
        _realmId = realm.getAtProviderId(_observedComposedResources)
        _roleName = "realm-admin"
        _serviceAccountUserId = crossplaneClient.getServiceAccountUserId(_observedComposedResources)
        _uses = [
            realmManagementClientObserve.managedResource
        ]
    }
    providerConfigCredentials: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_name}-provider-config-credentials"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "${_name}-provider-config-credentials"
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

