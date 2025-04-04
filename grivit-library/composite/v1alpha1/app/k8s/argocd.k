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

    kcArgoCdClient: core.KcOpenIdClientArgoCdWrapper {
        _argoCdDomain = _argoCdDomain
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName = _argoCdProjectName
        _keycloakInstanceName = _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId = _keycloakRealmId
        _projectName = _claimNamespace
    }
#    kcArgoCdClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
#        _additionalScopes = ["groups"]
#        _clientId = kcArgoCdClient.getAtProviderId(_observedComposedResources)
#        _instanceName = _keycloakInstanceName
#        _instanceOwnerProjectName = _projectNamespace
#        _name = "${_name}-argocd-client-default-scopes"
#        _projectNamespace = _projectNamespace
#        _realmId = _keycloakRealmId
#        _uses = [
#            kcArgoCdClient.managedResource
#        ]
#    }
    kcArgoCdAdminsGroup: core.KcGroupArgoCdWrapper {
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
        _argoCdProjectName= _argoCdProjectName
        _groupType = "admins"
        _keycloakInstanceName = _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId = _keycloakRealmId
        _projectName = _claimNamespace
        _uses = [
            #kcArgoCdClientDefaultScopes.managedResource
        ]
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}"
        _helmRepoUrl = "https://argoproj.github.io/argo-helm"
        _projectNamespace = _claimNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _kubernetesClusterName
        _name = "${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}"
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
requestedScopes: ["openid", "profile", "email", "groups"]

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
        _keycloakInstanceName= _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId= _keycloakRealmId
        _projectName = _claimNamespace
        _uses = [
            helmRelease.managedResource
        ]
    }
#    providerConfigKcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
#        _additionalScopes = ["groups"]
#        _clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
#        _instanceName = _keycloakInstanceName
#        _instanceOwnerProjectName = _projectNamespace
#        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-client-default-scopes"
#        _projectName = _projectNamespace
#        _realmId = _keycloakRealmId
#        _uses = [
#            providerConfigKcClient.managedResource
#        ]
#    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _keycloakInstanceName= _keycloakInstanceName
        _keycloakInstanceOwnerProjectName = _keycloakInstanceOwnerProjectName
        _keycloakRealmId= _keycloakRealmId
        _keycloakUserId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _projectName = _claimNamespace
        _managedResourceName = "${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-admins"
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _keycloakClientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _keycloakClientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _keycloakDomain = _keycloakDomain
        _keycloakRealmId = _keycloakRealmId
        _managedResourceName = "${_claimNamespace}-argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-admin"
        _projectName = _claimNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            #providerConfigKcClientDefaultScopes.managedResource
        ]
    }
#    providerConfigCredentialsSecret: core.ArgoCdProviderConfigK8sCredentialsSecretWrapper {
#        _argoCdProjectName = "admin"
#        _argoCdInstanceName = _argoCdInstanceName
#        _argoCdInstanceOwnerProjectName = _argoCdInstanceOwnerProjectName
#        _jwtToken = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
#        _projectNamespace = _claimNamespace
#        _uses = [
#            providerConfigHttpJwtToken.managedResource
#        ]
#    }

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
        _argoCdProjectName = "admin"
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
        #kcArgoCdClientDefaultScopes.managedResource
        kcArgoCdAdminsGroup.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        providerConfigKcClient.managedResource
        #providerConfigKcClientDefaultScopes.managedResource
        kcUserGroupsWrapper.managedResource
        providerConfigHttpJwtToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
    ]
    usages: [core.Usage] = sum([
        kcArgoCdClient.usages
        #kcArgoCdClientDefaultScopes.usages
        kcArgoCdAdminsGroup.usages
        helmRepo.usages
        helmRelease.usages
        providerConfigKcClient.usages
        #providerConfigKcClientDefaultScopes.usages
        kcUserGroupsWrapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
    ], [])

