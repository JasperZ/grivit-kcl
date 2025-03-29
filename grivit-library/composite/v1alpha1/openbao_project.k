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
        _loginRoleId = appRoleAuthBackendRole.getAtProviderId(_observedComposedResources)
        _loginSecretIdResourceName = appRoleAuthBackendRoleSecretId.managedResource.metadata.name
        _name = "${_projectName}-approle-auth-backend-login"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    managedResources: [core.ManagedResource | core.OpenBaoProviderConfig] = [
        approleAuthBackend.managedResource
        appRoleAuthBackendRole.managedResource
        appRoleAuthBackendRoleSecretId.managedResource
        appRoleAuthBackendLogin.managedResource
    ]

    usages: [core.Usage] = sum([
        approleAuthBackend.usages
        appRoleAuthBackendRole.usages
        appRoleAuthBackendRoleSecretId.usages
        appRoleAuthBackendLogin.usages
    ], [])