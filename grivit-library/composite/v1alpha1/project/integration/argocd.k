import crypto
import core.v1alpha1 as core

schema ArgoCdProjectIntegration:
    _argoCdInstance: core.ArgoCdInstance
    _claimName: str
    _claimNamespace: str
    _keycloakInstance: core.KeycloakInstance
    _observedComposedResources: any
    _targetProjectName: str

    _argoCdInstanceTargetProject: core.ArgoCdInstance {
        domain = _argoCdInstance.domain
        name = _argoCdInstance.name
        ownerProjectName = _argoCdInstance.ownerProjectName
        projectName = _targetProjectName
    }
    _managedResourcePrefix = crypto.md5("${_claimNamespace}-${_claimName}-argocd-${_argoCdInstanceTargetProject.ownerProjectName}-${_argoCdInstanceTargetProject.name}") + "-" + _argoCdInstanceTargetProject.projectName + "-"

    providerConfigKcClient: core.KcOpenIdClientArgoCdXpProviderWrapper {
        _argoCdInstance = _argoCdInstance
        _keycloakClientId = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_targetProjectName}-crossplane"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}crossplane"
    }
    kcArgoCdAdminsGroup: core.KcGroupWrapper {
        _keycloakGroupName = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_targetProjectName}-admins"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}admins"
    }
    kcArgoCdViewersGroup: core.KcGroupWrapper {
        _keycloakGroupName = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_targetProjectName}-viewers"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}viewers"
    }
    kcArgoCdAdminsGroupId: str = kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcArgoCdAdminsGroupId] if kcArgoCdAdminsGroupId else []
        _keycloakInstance = _keycloakInstance
        _keycloakUserId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _projectName = _claimNamespace
        _managedResourceName = "${_managedResourcePrefix}crossplane-sa-groups"
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    groupsMapper: core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = ""
        _clientScopeId = ""
        _keycloakInstance = _keycloakInstance
        _name = "${_managedResourcePrefix}groups-mapper"
        _projectName = _claimNamespace
        managedResource.spec.forProvider = {
            addToAccessToken = True
            claimName = "groups"
            clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
            fullPath = False
            name = "groups"
            realmId = _keycloakInstance.realmId
        }
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _keycloakClientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _keycloakClientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _keycloakInstance = _keycloakInstance
        _managedResourceName = "${core.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceTargetProject)}-token"
        _projectName = _claimNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
        ]
    }
    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = core.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceTargetProject)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.argoCdProviderConfigSecretName(_targetProjectName, _argoCdInstanceTargetProject)
        _stringData = {
            value = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
        }
        _uses = [
            providerConfigHttpJwtToken.managedResource
        ]
    }
    providerConfig: core.ArgoCdProviderConfigWrapper {
        _argoCdInstance = _argoCdInstanceTargetProject
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectName = _targetProjectName
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    argoCdControlPlaneProject: core.ArgoCdProjectWrapper {
        _argoCdInstance = _argoCdInstance
        _argoCdProjectDescription = "${_targetProjectName} - Control Plane Cluster"
        _argoCdProjectDestinations = [
            {name = "instance-cluster", namespace = _targetProjectName}
        ]
        _argoCdProjectRoles = [
            {
                description = "Project admin"
                groups = [kcArgoCdAdminsGroup.managedResource.spec.forProvider.name]
                name = "admins"
                # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                policies = [
                    "p, proj:${_managedResourcePrefix}controlplane:admins, applications, *, ${_managedResourcePrefix}controlplane/*, allow"
                    "p, proj:${_managedResourcePrefix}controlplane:admins, clusters, get, ${_managedResourcePrefix}controlplane/*, allow"
                    "p, proj:${_managedResourcePrefix}controlplane:admins, repositories, *, ${_managedResourcePrefix}controlplane/*, allow"
                ]
            }
            {
                description = "Project viewer"
                groups = [kcArgoCdViewersGroup.managedResource.spec.forProvider.name]
                name = "viewers"
                # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                policies = [
                    "p, proj:${_managedResourcePrefix}controlplane:viewers, applications, get, ${_managedResourcePrefix}controlplane/*, allow"
                    "p, proj:${_managedResourcePrefix}controlplane:viewers, clusters, get, ${_managedResourcePrefix}controlplane/*, allow"
                    "p, proj:${_managedResourcePrefix}controlplane:viewers, repositories, get, ${_managedResourcePrefix}controlplane/*, allow"
                ]
            }
        ]
        _argoCdProjectSourceNamespaces = [_targetProjectName]
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}controlplane"
    }
    argoCdTenantProject: core.ArgoCdProjectWrapper {
        _argoCdInstance = _argoCdInstance
        _argoCdProjectDescription = "${_targetProjectName} - Tenant Clusters"
        _argoCdProjectDestinations = [
            {name = "!instance-cluster", namespace = "*"}
        ]
        _argoCdProjectRoles = [
            {
                description = "Project admin"
                groups = [kcArgoCdAdminsGroup.managedResource.spec.forProvider.name]
                name = "admins"
                # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                policies = [
                    "p, proj:${_managedResourcePrefix}tenant:admins, applications, *, ${_managedResourcePrefix}tenant/*, allow"
                    "p, proj:${_managedResourcePrefix}tenant:admins, clusters, get, ${_managedResourcePrefix}tenant/*, allow"
                    "p, proj:${_managedResourcePrefix}tenant:admins, repositories, *, ${_managedResourcePrefix}tenant/*, allow"
                ]
            }
            {
                description = "Project viewer"
                groups = [kcArgoCdViewersGroup.managedResource.spec.forProvider.name]
                name = "viewers"
                # Syntax: p, <role/user/group>, <resource>, <action>, <object>, <effect>
                policies = [
                    "p, proj:${_managedResourcePrefix}tenant:viewers, applications, get, ${_managedResourcePrefix}tenant/*, allow"
                    "p, proj:${_managedResourcePrefix}tenant:viewers, clusters, get, ${_managedResourcePrefix}tenant/*, allow"
                    "p, proj:${_managedResourcePrefix}tenant:viewers, repositories, get, ${_managedResourcePrefix}tenant/*, allow"
                ]
            }
        ]
        _argoCdProjectSourceNamespaces = [_targetProjectName]
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}tenant"
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdAdminsGroup.managedResource
        kcArgoCdViewersGroup.managedResource
        providerConfigKcClient.managedResource
        kcUserGroupsWrapper.managedResource
        groupsMapper.managedResource
        providerConfigHttpJwtToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        argoCdControlPlaneProject.managedResource
        argoCdTenantProject.managedResource
    ]
    usages: [core.Usage] = sum([
        kcArgoCdAdminsGroup.usages
        kcArgoCdViewersGroup.usages
        providerConfigKcClient.usages
        kcUserGroupsWrapper.usages
        groupsMapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        argoCdControlPlaneProject.usages
        argoCdTenantProject.usages
    ], [])
