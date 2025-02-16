import core.v1alpha1 as core

schema OsStage:
    _controlPlaneK8sProviderConfigName: str
    _controlPlaneOsProviderConfigName: str
    _domain: str
    _email: str
    _name: str
    _observedComposedResources: any
    _projectName: str
    _tenantNamespace: str

    password: core.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _name = "${_name}-password"
        _secretName = "${_name}-password"
        _stringData = {
            # ToDo: hard coded password
            password = "gfjhgfjgfjgfjhg"
        }
        _targetNamespace = _tenantNamespace
    }
    project: core.OsIdentityProjectWrapper {
        _controlPlaneOsProviderConfigName = _controlPlaneOsProviderConfigName
        _projectName = _projectName
    }
    user: core.OsIdentityUserWrapper {
        _controlPlaneOsProviderConfigName = _controlPlaneOsProviderConfigName
        _name = "${_name}-user"
        _projectId = project.getProjectId(_observedComposedResources)
        _projectName = project.managedResource.metadata.name
        _passwordSecret = password
        _passwordSecretKey = "password"
        _userName = "${_projectName}-crossplane"
        _uses = [password.managedResource]
    }
    userRoleAssignment: core.OsIdentityRoleAssignmentWrapper {
        _controlPlaneOsProviderConfigName = _controlPlaneOsProviderConfigName
        _name = "${_name}-user-role-assignment"
        _projectId = project.getProjectId(_observedComposedResources)
        _userId = user.getUserId(_observedComposedResources)
    }
    cloudConfig: core.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _name = "${_name}-cloud-config"
        _secretName = "${_name}-cloud-config"
        _stringData = {
            # ToDo: Hard coded url
            value = """\
    {
    "auth_url": "https://test.grivit.cloud:5000",
    "insecure": "false",
    "tenant_id": "${project.getProjectId(_observedComposedResources)}",
    "tenant_name": "${project.managedResource.spec.forProvider.name}",
    "user_domain_name": "Default",
    "user_name": "${user.managedResource.spec.forProvider.name}",
    "password": "${password._stringData.password}"
    }
    """
        }
        _targetNamespace = _tenantNamespace
        _uses = [
            project.managedResource
            user.managedResource
            userRoleAssignment.managedResource
        ]
    }
    providerConfig: core.OsProviderConfigWrapper {
        _name = "${_name}-os-provider-config"
        _credentialsSecretName = cloudConfig.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = cloudConfig.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            cloudConfig.managedResource
        ]
    }
    zone: core.OsDnsZoneWrapper {
        _domain = _domain
        _email = _email
        _name = "${_name}-zone"
        _targetOsProviderConfig = providerConfig
        _uses = [providerConfig.managedResource]
    }
    managedResources: [core.ManagedResource | core.OsProviderConfig] = [
        password.managedResource
        project.managedResource
        user.managedResource
        userRoleAssignment.managedResource
        cloudConfig.managedResource
        providerConfig.managedResource
        zone.managedResource
    ]

    usages: [core.Usage] = password.usages + project.usages + user.usages + userRoleAssignment.usages + cloudConfig.usages + providerConfig.usages + zone.usages

