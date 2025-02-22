import core.v1alpha1 as core

schema K8sAppOperationsArgoCd:
    _clusterName: str
    _domain: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _kcInstanceName: str
    _kcRealmId: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    kcArgoCdClient: core.KcOpenIdClientWrapper {
        _clientId = "${_name}-argocd"
        _instanceName = _kcInstanceName
        _name = "${_name}-argocd-client"
        _realmId = _kcRealmId
        _redirectUri = "https://${_domain}/auth/callback"
        _projectNamespace = _projectNamespace
        _url = "https://${_domain}"
    }
    kcArgoCdClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = kcArgoCdClient.getAtProviderId(_observedComposedResources)
        _instanceName = _kcInstanceName
        _name = "${_name}-argocd-client-default-scopes"
        _realmId = _kcRealmId
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://argoproj.github.io/argo-helm"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "argo-cd"
        _helmChartVersion = "7.7.10"
        _helmReleaseName = "argocd"
        _helmReleaseNamespace = "argocd"
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
issuer: https://keycloak.nonprod-test1.test.grivit.com/realms/${_kcRealmId}
clientID: ${kcArgoCdClient.managedResource.spec.forProvider.clientId}
clientSecret: ${kcArgoCdClient.getClientSecret(_observedComposedResources)}
requestedScopes: ["openid", "profile", "email", "groups"]
"""
                }
                params = {
                    "server.insecure" = True
                }
                rbac = {
                    "policy.csv" = """\
p, role:authenticated, *, *, *, deny

g, admin, role:admin
g, viewer, role:readonly
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
            global.domain = _domain
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
    }
    managedResources: [core.ManagedResource] = [
        kcArgoCdClient.managedResource
        kcArgoCdClientDefaultScopes.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
    ]
    usages: [core.Usage] = sum([
        kcArgoCdClient.usages
        kcArgoCdClientDefaultScopes.usages
        helmRepo.usages
        helmRelease.usages
    ], [])

