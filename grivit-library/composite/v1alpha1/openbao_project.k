import json
import core.v1alpha1 as core

schema OpenBaoProject:
    _observedComposedResources: any
    _openBaoDomain: str
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _projectName: str
    _projectNamespace: str

    approleAuthBackend: core.OpenBaoAuthBackendWrapper {
        _backendDescription = "AppRole auth backend for project '${_projectName}' managed by Crossplane."
        _backendType= "approle"
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-approle-auth-backend"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    appRoleAuthBackendRole: core.OpenBaoAppRoleAuthBackendRoleWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-approle-auth-backend-role"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _roleName = "${_projectName}-crossplane-project-admin"
        _roleTokenPolicies = ["default"]
    }

    appRoleAuthBackendRoleSecretId: core.OpenBaoAppRoleAuthBackendRoleSecretIdWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-approle-auth-backend-role-secret-id"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _roleName = appRoleAuthBackendRole.managedResource.spec.forProvider.roleName
    }

    appRoleAuthBackendLogin: core.OpenBaoAppRoleAuthBackendLoginWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _loginRoleId = appRoleAuthBackendRole.getAtProviderRoleId(_observedComposedResources)
        _loginSecretIdResourceName = appRoleAuthBackendRoleSecretId.managedResource.metadata.name
        _name = "${_projectName}-approle-auth-backend-login"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    kvMount: core.OpenBaoMountWrapper {
        _mountType= "kv-v2"
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-kv-mount"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    kvSecretBackend: core.OpenBaoKvSecretBackendV2Wrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-kv-secret-backendv2"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    providerConfigPolicy: core.OpenBaoPolicyWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-crossplane-provider"
        _policyName = "${_projectName}-crossplane-provider"
        _policyDocument = """\
path "${_projectName}/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "scan"]
}
"""
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = core.openBaoProviderConfigSecretName(_projectName, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = core.openBaoProviderConfigSecretName(_projectName, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
        _stringData = {
            value = json.encode({
                token = "tbd"
            })
        }
    }
    
    providerConfig: core.OpenBaoProviderConfigWrapper {
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _openBaoDomain = _openBaoDomain
        _openBaoInstanceContext = _projectName
        _openBaoInstanceName= _openBaoInstanceName
        _openBaoInstanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _projectName = _projectName
    }

    managedResources: [core.ManagedResource | core.OpenBaoProviderConfig] = [
        approleAuthBackend.managedResource
        appRoleAuthBackendRole.managedResource
        appRoleAuthBackendRoleSecretId.managedResource
        appRoleAuthBackendLogin.managedResource
        kvMount.managedResource
        kvSecretBackend.managedResource
        providerConfigPolicy.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
    ]

    usages: [core.Usage] = sum([
        approleAuthBackend.usages
        appRoleAuthBackendRole.usages
        appRoleAuthBackendRoleSecretId.usages
        appRoleAuthBackendLogin.usages
        kvMount.usages
        kvSecretBackend.usages
        providerConfigPolicy.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
    ], [])