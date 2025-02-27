import core.v1alpha1 as core

schema KcProject:
    _domain: str
    _instanceName: str
    _instanceOwnerProjectName: str = _projectNamespace
    _name: str
    _observedComposedResources: any
    _projectNamespace: str
    _realmId: str

    realm = core.KcRealmWrapper {
        _instanceName = _instanceName
        _name = "${_name}-realm"
        _projectNamespace = _projectNamespace
        _realmId = _realmId
    }

    adminGroup = core.KcGroupWrapper {
        _groupName = "admin"
        _instanceName = _instanceName
        _name = "${_name}-admin-group"
        _projectNamespace = _projectNamespace
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
    crossplaneClient: core.KcOpenIdClientKcXpProviderWrapper {
        _instanceName = _instanceName
        _projectNamespace = _projectNamespace
        _realmId = realm.managedResource.spec.forProvider.realm
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
        _credentialsSecretName = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-master-provider"
        _credentialsSecretNamespace = _projectNamespace
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
        # Use provider for master realm to setup crossplane client
        managedResource.spec.providerConfigRef.name = "${_projectNamespace}-kc-${_instanceName}-master"
        _uses = [
            realmManagementClientObserve.managedResource
        ]
    }
    providerConfigCredentials: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-${_realmId}-provider"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "${_projectNamespace}-kc-${_instanceOwnerProjectName}-${_instanceName}-${_realmId}-provider"
        _stringData = {
            value = """\
{
  "client_id": "${crossplaneClient.managedResource.spec.forProvider.clientId}",
  "client_secret": "${crossplaneClient.getClientSecret(_observedComposedResources)}",
  "url": "https://${_domain}",
  "base_path": "/",
  "realm": "${_realmId}"
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
        _name = "${_projectNamespace}-kc-${_instanceName}-${_realmId}"
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

