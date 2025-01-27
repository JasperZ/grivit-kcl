import  as res

schema OsStage:
    _controlPlaneK8sProviderConfigName: str
    _controlPlaneOsProviderConfigName: str
    _domain: str
    _email: str
    _name: str
    _observedCompositeResource: any
    _projectName: str
    _tenantNamespace: str

    password: res.K8sOb0jectSecretWrapper {
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _name = "${_name}-password"
        _stringData = {
            # ToDo: hard coded password
            password = "gfjhgfjgfjgfjhg"
        }
        _targetNamespace = _tenantNamespace
    }
    project: res.OsIdentityProjectWrapper {
        _controlPlaneOsProviderConfigName = _controlPlaneOsProviderConfigName
        _projectName = _projectName
    }
    user: res.OsIdentityUserWrapper {
        _controlPlaneOsProviderConfigName = _controlPlaneOsProviderConfigName
        _name = "${_name}-user"
        _projectId = project.getProjectId(_observedCompositeResource)
        _projectName = project.managedResource.metadata.name
        _passwordSecret = password
        _passwordSecretKey = "password"
        _userName = "${_projectName}-crossplane"
        _uses = [password.managedResource]
    }
    userRoleAssignment: res.OsIdentityRoleAssignmentWrapper {
        _controlPlaneOsProviderConfigName = _controlPlaneOsProviderConfigName
        _name = "${_name}-user-role-assignment"
        _projectId = project.getProjectId(_observedCompositeResource)
        _userId = user.getUserId(_observedCompositeResource)
    }
    cloudConfig: res.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _name = "${_name}-cloud-config"
        _stringData = {
            # ToDo: Hard coded url
            value = """\
    {
    "auth_url": "https://test.grivit.cloud:5000",
    "insecure": "false",
    "tenant_id": "${project.getProjectId(_observedCompositeResource)}",
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
    providerConfig: res.OsProviderConfigWrapper {
        _name = "${_name}-os-provider-config"
        _credentialsSecretName = cloudConfig.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = cloudConfig.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            cloudConfig.managedResource
        ]
    }
    zone: res.OsDnsZoneWrapper {
        _domain = _domain
        _email = _email
        _name = "${_name}-zone"
        _targetOsProviderConfig = providerConfig
        _uses = [providerConfig.managedResource]
    }
    managedResources: [res.ManagedResource | res.OsProviderConfig] = [
        password.managedResource
        project.managedResource
        user.managedResource
        userRoleAssignment.managedResource
        cloudConfig.managedResource
        providerConfig.managedResource
        zone.managedResource
    ]

    usages: [res.Usage] = password.usages + project.usages + user.usages + userRoleAssignment.usages + cloudConfig.usages + providerConfig.usages + zone.usages

