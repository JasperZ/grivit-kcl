import xresources.v1alpha1 as res

_observedComposedResources: any = option("params").oxr
_observedCompositeResource: any = option("params").ocds

_claimName: str = _observedComposedResources.metadata.name
_claimNamespace: str = _observedComposedResources.metadata.labels["crossplane.io/claim-namespace"]
_spec: any = _observedComposedResources.spec

schema OsStage:
    password: res.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _spec.controlPlaneK8sProviderConfigName
        _name = "${_claimName}-password"
        _stringData = {
            # ToDo: hard coded password
            password = "gfjhgfjgfjgfjhg"
        }
        _targetNamespace = _claimNamespace
    }
    project: res.OsIdentityProjectWrapper {
        _controlPlaneOsProviderConfigName = _spec.controlPlaneOsProviderConfigName
        _projectName = _spec.projectName
    }
    user: res.OsIdentityUserWrapper {
        _controlPlaneOsProviderConfigName = _spec.controlPlaneOsProviderConfigName
        _name = "${_claimName}-user"
        _projectId = project.getProjectId(_observedCompositeResource)
        _projectName = _projectName
        _passwordSecret = password
        _passwordSecretKey = "password"
        _userName = "${_spec.projectName}-crossplane"
        _uses = [password.managedResource]
    }
    userRoleAssignment: res.OsIdentityRoleAssignmentWrapper {
        _controlPlaneOsProviderConfigName = _spec.controlPlaneOsProviderConfigName
        _name = "${_claimName}-user-role-assignment"
        _projectId = project.getProjectId(_observedCompositeResource)
        _userId = user.getUserId(_observedCompositeResource)
    }
    cloudConfig: res.K8sObjectSecretWrapper {
        _targetK8sProviderConfigName = _spec.controlPlaneK8sProviderConfigName
        _name = "${_claimName}-cloud-config"
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
        _targetNamespace = _claimNamespace
        _uses = [
            project.managedResource
            user.managedResource
            userRoleAssignment.managedResource
        ]
    }
    providerConfig: res.OsProviderConfigWrapper {
        _name = "${_claimName}-os-provider-config"
        _credentialsSecretName = cloudConfig.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = cloudConfig.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            cloudConfig.managedResource
        ]
    }
    zone: res.OsDnsZoneWrapper {
        _domain = _spec.domain
        _email = _spec.email
        _name = "${_claimName}-zone"
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

