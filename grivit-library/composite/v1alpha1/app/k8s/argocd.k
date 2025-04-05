import crypto
import core.v1alpha1 as core
import core.v1alpha1.argocd_utils as argoCdUtils

schema ArgoCdAppK8s:
    _argoCdDomain: str
    _argoCdInstanceName: str
    _argoCdInstanceOwnerProjectName: str
    _argoCdProjectName: str
    _claimNamespace: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _keycloakDomain: str
    _keycloakInstanceName: str
    _keycloakInstanceOwnerProjectName: str
    _keycloakRealmId: str
    _kubernetesClusterName: str
    _observedComposedResources: any

    _managedResourcePrefix = crypto.md5("${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}") + "-" + _argoCdProjectName + "-"

    kcArgoCdClient: core.KcOpenIdClientArgoCdWrapper {
        _argoCdDomain = _argoCdDomain
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName = _argoCdProjectName
        _keycloakClientId = "argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-client"
        _keycloakInstanceName = _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId = _keycloakRealmId
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}client"
    }
    kcArgoCdAdminsGroup: core.KcGroupWrapper {
        _keycloakGroupName = "argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-admins"
        _keycloakInstanceName = _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId = _keycloakRealmId
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}admins"
    }
    kcArgoCdClientGroupMapper: core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = "dummy"
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_managedResourcePrefix}client-group-mapper"
        _projectNamespace = _claimNamespace
        _realmId = _keycloakRealmId
        
        managedResource.spec.forProvider = {
            addToAccessToken = True
            claimName = "groups"
            clientId = kcArgoCdClient.getAtProviderId(_observedComposedResources)
            fullPath = False
            name = "groups"
            realmId = _keycloakRealmId
        }
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_managedResourcePrefix}repo"
        _helmRepoUrl = "https://argoproj.github.io/argo-helm"
        _projectNamespace = _claimNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _kubernetesClusterName
        _name = "${_managedResourcePrefix}rel"
        _helmChartName = "argo-cd"
        _helmChartVersion = "7.7.10"
        _helmReleaseName = "argocd-${_argoCdInstanceName}"
        _helmReleaseNamespace = "argocd-${_argoCdInstanceName}"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _claimNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            applicationSet = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
                resources = {
                    limits.cpu = "100m"
                    limits.memory = "128Mi"
                    requests.cpu = "100m"
                    requests.memory = "128Mi"
                }
            }
            configs = {
                cm = {
                    "oidc.config" = """\
name: Keycloak
issuer: https://${_keycloakDomain}/realms/${_keycloakRealmId}
clientID: ${kcArgoCdClient.managedResource.spec.forProvider.clientId}
clientSecret: ${kcArgoCdClient.getClientSecret(_observedComposedResources)}
requestedScopes: ["openid", "profile", "email"]

#ToDo: Workaround until it's easier to set the client id as audience in the crossplane keycloak provider
allowedAudiences:
  - ${kcArgoCdClient.managedResource.spec.forProvider.clientId}
  - account
"""
                }
                params = {
                    "server.insecure" = True
                }
                rbac = {
                    "policy.csv" = """\
p, role:authenticated, *, *, *, deny

g, ${kcArgoCdAdminsGroup.managedResource.spec.forProvider.name}, role:admin
"""
                    "policy.default" = "role:authenticated"
                    scopes = "[groups]"
                }
            }
            controller = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
                resources = {
                    limits.cpu = "300m"
                    limits.memory = "1024Mi"
                    requests.cpu = "300m"
                    requests.memory = "1024Mi"
                }
            }
            dex.enabled = False
            redis.metrics = {
                enabled = True
                serviceMonitor = {
                    enabled = True
                }
            }
            redis.resources = {
                limits.cpu = "100m"
                limits.memory = "128Mi"
                requests.cpu = "100m"
                requests.memory = "128Mi"
            }
            global.domain = _argoCdDomain
            notifications.enabled = False
            notifications.metrics = {
                enabled = True
                serviceMonitor = {
                    enabled = True
                }
            }
            repoServer = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
                resources = {
                    limits.cpu = "200m"
                    limits.memory = "256Mi"
                    requests.cpu = "200m"
                    requests.memory = "256Mi"
                }
            }
            server = {
                ingress = {
                    annotations = {
                        "cert-manager.io/cluster-issuer" = "letsencrypt"
                    }
                    enabled = True
                    ingressClassName = "nginx"
                    tls = True
                }
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
                resources = {
                    limits.cpu = "100m"
                    limits.memory = "128Mi"
                    requests.cpu = "100m"
                    requests.memory = "128Mi"
                }
            }
        }
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    providerConfigKcClient: core.KcOpenIdClientArgoCdXpProviderWrapper {
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName = _argoCdProjectName
        _keycloakClientId = "argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-crossplane"
        _keycloakInstanceName= _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId= _keycloakRealmId
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}crossplane"
        _uses = [
            helmRelease.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _keycloakInstanceName= _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId= _keycloakRealmId
        _keycloakUserId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _projectName = _claimNamespace
        _managedResourceName = "${_managedResourcePrefix}provider-user-groups"
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    groupsMapper: core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = "dummy"
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _name = "${_managedResourcePrefix}provider-group-mapper"
        _projectNamespace = _claimNamespace
        _realmId = _keycloakRealmId
        
        managedResource.spec.forProvider = {
            addToAccessToken = True
            claimName = "groups"
            clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
            fullPath = False
            name = "groups"
            realmId = _keycloakRealmId
        }
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _keycloakClientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _keycloakClientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _keycloakDomain = _keycloakDomain
        _keycloakRealmId = _keycloakRealmId
        _managedResourceName = "${_managedResourcePrefix}admin"
        _projectName = _claimNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            #providerConfigKcClientDefaultScopes.managedResource
        ]
    }

    _providerConfigCredentialsSecretName: str = argoCdUtils.argoCdProviderConfigSecretName(_claimNamespace, _argoCdInstanceOwnerProjectName, _argoCdInstanceName, _argoCdProjectName)
    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name= _providerConfigCredentialsSecretName
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = _providerConfigCredentialsSecretName
        _stringData = {
            value = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
        }
        _uses = [
            providerConfigHttpJwtToken.managedResource
        ]
    }

    providerConfig: core.ArgoCdProviderConfigWrapper {
        _argoCdDomain = _argoCdDomain
        _argoCdProjectName = _argoCdProjectName
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectName = _claimNamespace
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdClient.managedResource
        kcArgoCdAdminsGroup.managedResource
        kcArgoCdClientGroupMapper.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        providerConfigKcClient.managedResource
        kcUserGroupsWrapper.managedResource
        groupsMapper.managedResource
        providerConfigHttpJwtToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
    ]
    usages: [core.Usage] = sum([
        kcArgoCdClient.usages
        kcArgoCdAdminsGroup.usages
        kcArgoCdClientGroupMapper.usages
        helmRepo.usages
        helmRelease.usages
        providerConfigKcClient.usages
        kcUserGroupsWrapper.usages
        groupsMapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
    ], [])


    check:
        len(managedResources) == len({managedResource.metadata.name: True for managedResource in managedResources}), "Names of managed Resources must be unique"