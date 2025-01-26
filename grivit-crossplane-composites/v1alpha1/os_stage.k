import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.os.core.v1 as cpOsCore

_observedComposedResources: any = option("params").oxr
_observedCompositeResource: any = option("params").ocds

_claimName: str = _observedComposedResources.metadata.name
_claimNamespace: str = _observedComposedResources.metadata.labels["crossplane.io/claim-namespace"]
_spec: any = _observedComposedResources.spec

Schema OsStage:
    password: cpK8sCore.ObjectSecretWrapper {
        _targetK8sProviderConfigName = _spec.controlPlaneK8sProviderConfigName
        _name = "${_claimName}-password"
        _stringData = {
            # ToDo: hard coded password
            password = "gfjhgfjgfjgfjhg"
        }
        _targetNamespace = _claimNamespace
    }
    project: cpOsCore.IdentityProjectWrapper {
        _controlPlaneOsProviderConfigName = _spec.controlPlaneOsProviderConfigName
        _projectName = _spec.projectName
    }
    user: cpOsCore.IdentityUserWrapper {
        _controlPlaneOsProviderConfigName = _spec.controlPlaneOsProviderConfigName
        _name = "${_claimName}-user"
        _osProject = project
        _passwordSecret = password
        _passwordSecretKey = "password"
        _userName = "${_spec.projectName}-crossplane"
        _uses = [password.managedResource]
    }
    userRoleAssignment: cpOsCore.IdentityRoleAssignmentWrapper {
        _controlPlaneOsProviderConfigName = _spec.controlPlaneOsProviderConfigName
        _name = "${_claimName}-user-role-assignment"
        _osProject = project
        _osUser = user
    }
    _projectId = None
    _projectName = project.managedResource.metadata.name
    if _projectName in _observedComposedResources:
        _projectId = _observedComposedResources[_spec.projectName].Resource?.status?.atProvider?.id or ""

    cloudConfig: cpK8sCore.ObjectSecretWrapper {
        _targetK8sProviderConfigName = _spec.controlPlaneK8sProviderConfigName
        _name = "${_claimName}-cloud-config"
        _stringData = {
            # ToDo: Hard coded url
            value = """\
    {
    "auth_url": "https://test.grivit.cloud:5000",
    "insecure": "false",
    "tenant_id": "${_projectId}",
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
    providerConfig: cpOsCore.ProviderConfigWrapper {
        _name = "${_claimName}-os-provider-config"
        _credentialsSecretName = cloudConfig.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = cloudConfig.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            cloudConfig.managedResource
        ]
    }
    zone: cpOsCore.DnsZoneWrapper {
        _domain = _spec.domain
        _email = _spec.email
        _name = "${_claimName}-zone"
        _targetOsProviderConfig = providerConfig
        _uses = [providerConfig.managedResource]
    }
    managedResources: [cpCore.ManagedResource | cpOsCore.ProviderConfig] = [
        password.managedResource
        project.managedResource
        user.managedResource
        userRoleAssignment.managedResource
        cloudConfig.managedResource
        providerConfig.managedResource
        zone.managedResource
    ]

    usages: [cpCore.Usage] = password.usages + project.usages + user.usages + userRoleAssignment.usages + cloudConfig.usages + providerConfig.usages + zone.usages
