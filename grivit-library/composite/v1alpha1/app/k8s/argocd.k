import core.v1alpha1 as core
import core.v1alpha1.argocd_utils as argoCdUtils

schema ArgoCd:
    _argoCdDomain: str
    _argoCdInstanceName: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _keycloakDomain: str
    _keycloakInstanceName: str
    _keycloakRealmId: str
    _kubernetesClusterName: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    kcArgoCdClient: core.KcOpenIdClientArgoCdWrapper {
        _argoCdDomain = _argoCdDomain
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmId
    }
    kcArgoCdClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = kcArgoCdClient.getAtProviderId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _name = "${_name}-argocd-client-default-scopes"
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmId
        _uses = [
            kcArgoCdClient.managedResource
        ]
    }
    kcArgoCdAdminsGroup = core.KcGroupArgoCdWrapper {
        _groupType = "admins"
        _instanceName = _argoCdInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectName = "admin"
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmId
        _uses = [
            kcArgoCdClientDefaultScopes.managedResource
        ]
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://argoproj.github.io/argo-helm"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _kubernetesClusterName
        _name = "${_name}-rel"
        _helmChartName = "argo-cd"
        _helmChartVersion = "7.7.10"
        _helmReleaseName = "argocd-${_argoCdInstanceName}"
        _helmReleaseNamespace = "argocd-${_argoCdInstanceName}"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
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
        _instanceName = _argoCdInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectName = "admin"
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmId
        _uses = [
            helmRelease.managedResource
        ]
    }
    providerConfigKcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
        _instanceName = _keycloakInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-client-default-scopes"
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmId
        _uses = [
            providerConfigKcClient.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _groupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _instanceName = _argoCdInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectNamespace = _projectNamespace
        _realmId = _keycloakRealmId
        _userId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    providerConfigHttpJwtToken: core.KcOpenIdClientJwtWrapper {
        _clientId = providerConfigKcClient.managedResource.spec.forProvider.clientId
        _clientSecret = providerConfigKcClient.getClientSecret(_observedComposedResources)
        _domain = _keycloakDomain
        _name = "${argoCdUtils.argoCdProviderConfigName(_projectNamespace, _projectNamespace, _argoCdInstanceName, 'admin')}-token"
        _realmId = _keycloakRealmId
        _projectNamespace = _projectNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            providerConfigKcClientDefaultScopes.managedResource
        ]
    }
    providerConfigCredentialsSecret: core.ArgoCdProviderConfigK8sCredentialsSecretWrapper {
        _argoCdProjectName = "admin"
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _projectNamespace
        _jwtToken = providerConfigHttpJwtToken.getAccessToken(_observedComposedResources)
        _projectNamespace = _projectNamespace
        _uses = [
            providerConfigHttpJwtToken.managedResource
        ]
    }
    providerConfig: core.ArgoCdProviderConfigWrapper {
        _argoCdDomain = _argoCdDomain
        _argoCdProjectName = "admin"
        _argoCdInstanceName = _argoCdInstanceName
        _argoCdInstanceOwnerProjectName = _projectNamespace
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectNamespace = _projectNamespace
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdClient.managedResource
        kcArgoCdClientDefaultScopes.managedResource
        kcArgoCdAdminsGroup.managedResource
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
        kcArgoCdClient.usages
        kcArgoCdClientDefaultScopes.usages
        kcArgoCdAdminsGroup.usages
        helmRepo.usages
        helmRelease.usages
        providerConfigKcClient.usages
        providerConfigKcClientDefaultScopes.usages
        kcUserGroupsWrapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
    ], [])

