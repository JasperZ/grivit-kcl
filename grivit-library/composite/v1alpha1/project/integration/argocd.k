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
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
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
    argoCdProject: core.ArgoCdProjectWrapper {
        _argoCdInstance = _argoCdInstance
        _argoCdProjectAdminsGroupName = kcArgoCdAdminsGroup.managedResource.spec.forProvider.name
        _argoCdProjectViewersGroupName = kcArgoCdViewersGroup.managedResource.spec.forProvider.name
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}project"
    }
    argoCdInstanceCluster: core.ArgoCdClusterWrapper {
        _argoCdInstance = _argoCdInstance
        _argoCdClusterKubeconfigSecretKey= "value"
        _argoCdClusterKubeconfigSecretName = core.k8sProviderConfigSecretName(_claimNamespace, "ctrl")
        _argoCdClusterKubeconfigSecretNamespace = _claimNamespace
        _argoCdClusterName = "${_targetProjectName}-controlplane"
        _argoCdClusterNamespaces = [_targetProjectName]
        _argoCdClusterProject = argoCdProject.managedResource.metadata.name
        _projectName= _claimNamespace
        _resourceName: "${_managedResourcePrefix}instance"
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
        argoCdProject.managedResource
        argoCdInstanceCluster.managedResource
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
        argoCdProject.usages
        argoCdInstanceCluster.usages
    ], [])
