import json
import core.v1alpha1 as core

schema OpenBaoProject:
    _observedComposedResources: any
    _openBaoDomain: str
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _projectName: str
    _projectNamespace: str

    appRoleAuthBackend: core.OpenBaoAuthBackendWrapper {
        _backendDescription = "AppRole auth backend for project '${_projectName}' managed by Crossplane."
        _backendType= "approle"
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-approle-auth-backend"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    providerConfigPolicy: core.OpenBaoPolicyWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-crossplane-provider"
        _policyName = "${_projectName}-crossplane-provider"
        _policyDocument = """\
#path "${_projectName}/*" {
#  capabilities = ["create", "read", "update", "patch", "delete", "list", "scan"]
#}

path "*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "scan"]
}
"""
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    adminGroup: core.OpenBaoIdentityGroupWrapper {
        _groupName = "${_projectName}-admin"
        _groupPolicies= [providerConfigPolicy.managedResource.spec.forProvider.name]
        _groupType: "internal"
        _name = "${_projectName}-openbao-admin-group"
        _openBaoInstanceContext= "admin"
        _openBaoInstanceName= _openBaoInstanceName
        _openBaoInstanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _projectName = _projectName
    }

    appRoleAuthBackendRole: core.OpenBaoAppRoleAuthBackendRoleWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-approle-auth-backend-role"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _roleName = "${_projectName}-crossplane-project-admin"
        _roleTokenPolicies = ["default", providerConfigPolicy.managedResource.spec.forProvider.name]
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

    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = core.openBaoProviderConfigSecretName(_projectName, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = core.openBaoProviderConfigSecretName(_projectName, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
        _stringData = {
            value = json.encode({
                token = appRoleAuthBackendLogin.getClientToken(_observedComposedResources)
                #auth_login = {
                #    path = appRoleAuthBackend.managedResource.spec.forProvider.path
                #
                #    parameters = {
                #        role_id   = appRoleAuthBackendRole.getAtProviderRoleId(_observedComposedResources)
                #        secret_id = appRoleAuthBackendRoleSecretId.getSecretId(_observedComposedResources)
                #    }
                #}
            })
        }
    }
    
    providerConfig: core.OpenBaoProviderConfigWrapper {
        _credentialsSecretName = "413e0a633a73a0774da57ffe4abededf-admin-provider"
        _credentialsSecretNamespace = "grivit-ctrl-crossplane-dev"
        _openBaoDomain = _openBaoDomain
        _openBaoInstanceContext = _projectName
        _openBaoInstanceName= _openBaoInstanceName
        _openBaoInstanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _projectName = _projectName
    }

    k8sTestSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "k8s-test-secret"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "test-secret"
        _stringData = {
            value = "test value"
        }
    }

    baoTestSecret: core.OpenBaoKvSecretV2Wrapper {
        _name = "bao-test-secret"
        _openBaoInstanceName= _openBaoInstanceName
        _openBaoInstanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _secretDataJsonSecretRefKey = "value"
        _secretDataJsonSecretRefName = k8sTestSecret.managedResource.spec.forProvider.manifest.metadata.name
        _secretDataJsonSecretRefNamespace = k8sTestSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _secretName = json.encode({
            key1: "value1"
            key2: "value2"
            key3: "value3"
        })
    }

    managedResources: [core.ManagedResource | core.OpenBaoProviderConfig] = [
        appRoleAuthBackend.managedResource
        providerConfigPolicy.managedResource
        adminGroup.managedResource
        appRoleAuthBackendRole.managedResource
        appRoleAuthBackendRoleSecretId.managedResource
        appRoleAuthBackendLogin.managedResource
        kvMount.managedResource
        kvSecretBackend.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        k8sTestSecret.managedResource
        baoTestSecret.managedResource
    ]

    usages: [core.Usage] = sum([
        appRoleAuthBackend.usages
        providerConfigPolicy.usages
        adminGroup.usages
        appRoleAuthBackendRole.usages
        appRoleAuthBackendRoleSecretId.usages
        appRoleAuthBackendLogin.usages
        kvMount.usages
        kvSecretBackend.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        k8sTestSecret.usages
        baoTestSecret.usages
    ], [])