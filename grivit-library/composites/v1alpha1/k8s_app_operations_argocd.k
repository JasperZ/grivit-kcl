import core.v1alpha1 as core

schema K8sAppOperationsArgoCd:
    _controlPlaneK8sProviderConfigName: str
    _domain: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    # _realmId: str
    _targetK8sProviderConfigWrapper: core.K8sProviderConfigWrapper
    _targetKcProviderConfigWrapper: core.KcProviderConfigWrapper
    _tenantNamespace: str

    kcArgoCdClient: core.KcOpenIdClientWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _clientId = "${_name}-argocd"
        _name = "${_name}-argocd-client"
        # _realmId = _realmId
        _redirectUri = "https://${_domain}/auth/callback"
        _url = "https://${_domain}"
    }
    kcArgoCdClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _clientId = kcArgoCdClient.getId(_observedComposedResources)
        _name = "${_name}-argocd-client-default-scopes"
        # _realmId = _realmId
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://argoproj.github.io/argo-helm"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "argo-cd"
        _helmChartVersion = "7.7.10"
        _helmReleaseName = "argocd"
        _helmReleaseNamespace = "argocd"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            applicationSet = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
            }
            cm = {
                "oidc.config" = """\
name: Keycloak
issuer: https://keycloak.hub.test.grivit.com/realms/${kcArgoCdClient.managedResource.spec.forProvider.realmId}
clientID: ${kcArgoCdClient.managedResource.spec.forProvider.clientId}
clientSecret: ${kcArgoCdClient.getClientSecret(_observedComposedResources)}
requestedScopes: ["openid", "profile", "email", "groups"]
"""
            }
            configs.params = {
                "server.insecure" = True
            }
            controller = {
                metrics = {
                    enabled = True
                    serviceMonitor = {
                        enabled = True
                    }
                }
                replicas = 1
            }
            dex.enabled = False
            rbac = {
                "policy.csv" = """\
p, role:authenticated, *, *, *, deny

g, admin, role:admin
g, viewer, role:readonly
"""
                "policy.default" = "role:authenticated"
                scopes = "[groups]"
            }
            redi.metrics = {
                enabled = True
                serviceMonitor = {
                    enabled = True
                }
            }
            global.domain = _domain
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
            }
        }
    }
    managedResources: [core.ManagedResource] = [
        helmRepo.managedResource
        helmRelease.managedResource
    ]

    usages: [core.Usage] = helmRepo.usages + helmRelease.usages

