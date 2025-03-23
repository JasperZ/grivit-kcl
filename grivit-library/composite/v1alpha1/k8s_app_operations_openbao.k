import core.v1alpha1 as core
import core.v1alpha1.openbao_utils as openBaoUtils

schema K8sAppOperationsOpenBao:
    _clusterName: str
    _domain: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _instanceName: str
    _kcDomain: str
    _kcInstanceName: str
    _kcRealmId: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    kcOpenBaoClient: core.KcOpenIdClientOpenBaoWrapper {
        _openBaoDomain = _domain
        _instanceName = _kcInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
    }
    kcOpenBaoClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = kcOpenBaoClient.getAtProviderId(_observedComposedResources)
        _instanceName = _kcInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _name = "${_name}-openbao-client-default-scopes"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            kcOpenBaoClient.managedResource
        ]
    }
    kcOpenBaoAdminsGroup = core.KcGroupOpenBaoWrapper {
        _groupType = "admins"
        _instanceName = _instanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectName = "admin"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            kcOpenBaoClientDefaultScopes.managedResource
        ]
    }
    k8sServiceAccount: core.K8sObjectServiceAccountWrapper {
        _clusterName = _clusterName
        _name = "${_name}-sa"
        _projectNamespace = _projectNamespace
        _serviceAccountName = "openbao"
        _serviceAccountNamespace= "openbao"
    }
    k8sRole: core.K8sObjectRoleWrapper {
        _clusterName = _clusterName
        _name = "${_name}-role"
        _projectNamespace = _projectNamespace
        _roleName = "openbao"
        _roleNamespace = "openbao"
        _roleRules = [
            {
                apiGroups = [""]
                resources = ["secrets"]
                verbs = ["get", "create", "update"]
            }
            {
                apiGroups = [""]
                resources = ["pods"]
                verbs = ["get"]
            }
            {
                apiGroups = [""]
                resources = ["pods/exec"]
                verbs = ["create"]
            }
        ]
    }
    k8sRoleBinding: core.K8sObjectRoleBindingWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rolebinding"
        _projectNamespace = _projectNamespace
        _roleBindingName = "openbao"
        _roleBindingNamespace = "openbao"
        _roleBindingSubjects = [
            {
                kind = k8sServiceAccount.managedResource.spec.forProvider.manifest.kind
                name = k8sServiceAccount.managedResource.spec.forProvider.manifest.metadata.name
                namespace = k8sServiceAccount.managedResource.spec.forProvider.manifest.metadata.name
            }
        ]
        _roleBindingRoleRefKind = k8sRole.managedResource.spec.forProvider.manifest.kind
        _roleBindingRoleRefName = k8sRole.managedResource.spec.forProvider.manifest.metadata.name
        _roleBindingRoleRefNamespace = k8sRole.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            k8sServiceAccount.managedResource
            k8sRole.managedResource
        ]    
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://openbao.github.io/openbao-helm"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "openbao"
        _helmChartVersion = "0.10.1"
        _helmReleaseName = "openbao"
        _helmReleaseNamespace = "openbao"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            server = {
                ingress = {
                    enabled = True
                    annotaions = {
                        "cert-manager.io/cluster-issuer" = "letsencrypt"
                    }
                    ingressClassName = "nginx"
                    hosts = [
                        {
                            host = _domain
                            paths = []
                        }
                    ]
                    tls = [
                        {
                            secretName = "${_domain}-tls"
                            hosts = [_domain]
                        }
                    ]
                }
                serviceAccount = {
                    create = False
                    name = k8sServiceAccount.managedResource.spec.forProvider.metadata.name
                }
            }
        }
        _uses = [
            kcOpenBaoAdminsGroup.managedResource
            k8sRoleBinding.managedResource
        ]
    }
    providerConfigKcClient: core.KcOpenIdClientOpenBaoXpProviderWrapper {
        _instanceName = _instanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectName = "admin"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            helmRelease.managedResource
        ]
    }
    providerConfigKcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
        _instanceName = _kcInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-client-default-scopes"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            providerConfigKcClient.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _groupIds = [kcOpenBaoAdminsGroup.getAtProviderId(_observedComposedResources)]
        _instanceName = _instanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _userId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _uses = [
            kcOpenBaoAdminsGroup.managedResource
        ]
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _clientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _clientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _domain = _kcDomain
        _name = "${openBaoUtils.openBaoProviderConfigName(_projectNamespace, _projectNamespace, _instanceName, 'admin')}-token"
        _realmId = _kcRealmId
        _projectNamespace = _projectNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    providerConfigCredentialsSecret: core.OpenBaoProviderConfigK8sCredentialsSecretWrapper {
        _openBaoInstanceName = _instanceName
        _openBaoInstanceOwnerProjectName = _projectNamespace
        _openBaoJwtToken = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
        _openBaoProjectName = "admin"
        _openBaoRole = ""
        _projectNamespace = _projectNamespace
        _uses = [
            providerConfigHttpJwtToken.managedResource
        ]
    }
    providerConfig: core.OpenBaoProviderConfigWrapper {
        _openBaoDomain = _domain
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _openBaoInstanceName = _instanceName
        _openBaoInstanceOwnerProjectName = _projectNamespace
        _openBaoProjectName = "admin"
        _projectNamespace = _projectNamespace
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    managedResources: [core.ManagedResource | core.OpenBaoProviderConfig] = [
        kcOpenBaoClient.managedResource
        kcOpenBaoClientDefaultScopes.managedResource
        kcOpenBaoAdminsGroup.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        providerConfigKcClient.managedResource
        providerConfigKcClientDefaultScopes.managedResource
        kcUserGroupsWrapper.managedResource
        providerConfigHttpJwtToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
    ]
    usages: [core.Usage] = sum([
        kcOpenBaoClient.usages
        kcOpenBaoClientDefaultScopes.usages
        kcOpenBaoAdminsGroup.usages
        helmRepo.usages
        helmRelease.usages
        providerConfigKcClient.usages
        providerConfigKcClientDefaultScopes.usages
        kcUserGroupsWrapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
    ], [])

