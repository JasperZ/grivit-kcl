import core.v1alpha1 as core

schema OsStage:
    _controlPlaneK8sProviderConfigName: str
    _controlPlaneOsProviderConfigName: str
    _domain: str
    _email: str
    _name: str
    _observedComposedResources: any
    _projectName: str
    _projectNamespace: str

    password: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_name}-password"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "${_name}-password"
        _stringData = {
            # ToDo: hard coded password
            password = "gfjhgfjgfjgfjhg"
        }
    }
    project: core.OsIdentityProjectWrapper {
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }
    user: core.OsIdentityUserWrapper {
        _name = "${_name}-user"
        _passwordSecret = password
        _passwordSecretKey = "password"
        _projectId = project.getProjectId(_observedComposedResources)
        _projectName = project.managedResource.metadata.name
        _projectNamespace = _projectNamespace
        _userName = "${_projectName}-crossplane"
        _uses = [password.managedResource]
    }
    userRoleAssignment: core.OsIdentityRoleAssignmentWrapper {
        _name = "${_name}-user-role-assignment"
        _projectId = project.getProjectId(_observedComposedResources)
        _projectNamespace = _projectNamespace
        _userId = user.getUserId(_observedComposedResources)
    }
    cloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_name}-cloud-config"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
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
        _uses = [
            project.managedResource
            user.managedResource
            userRoleAssignment.managedResource
        ]
    }
    providerConfig: core.OsProviderConfigWrapper {
        _name = _projectNamespace
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
        _projectNamespace = _projectNamespace
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

