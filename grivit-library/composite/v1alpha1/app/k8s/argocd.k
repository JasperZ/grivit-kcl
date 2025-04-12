import crypto
import core.v1alpha1 as core

schema ArgoCdAppK8s:
    _argoCdInstance: core.ArgoCdInstance
    _claimName: str
    _claimNamespace: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _keycloakInstance: core.KeycloakInstance
    _kubernetesClusterName: str
    _observedComposedResources: any

    _managedResourcePrefix = crypto.md5("${_claimNamespace}-${_claimName}-argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}") + "-" + _argoCdInstance.projectName + "-"

    kcArgoCdClient: core.KcOpenIdClientArgoCdWrapper {
        _argoCdInstance = _argoCdInstance
        _keycloakClientId = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_argoCdInstance.projectName}-client"
        _keycloakInstance = _keycloakInstance
        _argoCdInstance = _argoCdInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}client"
    }
    kcArgoCdAdminsGroup: core.KcGroupWrapper {
        _keycloakGroupName = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_argoCdInstance.projectName}-admins"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}admins"
    }
    kcArgoCdClientGroupMapper: core.KcOpenIdGroupMembershipProtocolMapperWrapper {
        _claimName = "groups"
        _clientScopeId = "dummy"
        _keycloakInstance = _keycloakInstance
        _name = "${_managedResourcePrefix}client-group-mapper"
        _projectName = _claimNamespace
        
        managedResource.spec.forProvider = {
            addToAccessToken = True
            claimName = "groups"
            clientId = kcArgoCdClient.getAtProviderId(_observedComposedResources)
            fullPath = False
            name = "groups"
            realmId = _keycloakInstance.realmId
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
        _helmChartVersion = "7.8.23"
        _helmReleaseName = "argocd-${_argoCdInstance.name}"
        _helmReleaseNamespace = "argocd-${_argoCdInstance.name}"
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
                    "application.resourceTrackingMethod" = "annotation+label"
                    "oidc.config" = """\
name: Keycloak
issuer: https://${_keycloakInstance.domain}/realms/${_keycloakInstance.realmId}
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
                    "application.namespaces" = "grivit-ctrl-*, grivit-cust-*"
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
            global.domain = _argoCdInstance.domain
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
                    limits.cpu = "200m"
                    limits.memory = "256Mi"
                    requests.cpu = "100m"
                    requests.memory = "128Mi"
                }
            }
        }
        _uses = [
            kcArgoCdAdminsGroup.managedResource
        ]
    }
    # Override default project
    # https://github.com/kahou82/argo-cd/blob/92f2c1374a7c7cd993a96f2dd95d1005cbfb9511/docs/user-guide/projects.md#the-default-project
    argoCdDefaultProject: core.K8sObjectGenericWrapper {
        _clusterName = _kubernetesClusterName
        _name = "${_managedResourcePrefix}default-project"
        _projectNamespace = _claimNamespace
        
        managedResource.spec.forProvider.manifest = {
            apiVersion = "argoproj.io/v1alpha1"
            kind = "AppProject"
            metadata.name = "default"
            metadata.namespace = "argocd-${_argoCdInstance.name}"
            spec = {
                sourceRepos = []
                sourceNamespaces = []
                destinations = []
                namespaceResourceBlacklist = [
                    {
                        group = "*"
                        kind = "*"
                    }
                ]
            }
        }
    }
    providerConfigKcClient: core.KcOpenIdClientArgoCdXpProviderWrapper {
        _argoCdInstance = _argoCdInstance
        _keycloakClientId = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_argoCdInstance.projectName}-crossplane"
        _keycloakInstance = _keycloakInstance
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}crossplane"
        _uses = [
            helmRelease.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcArgoCdAdminsGroup.getAtProviderId(_observedComposedResources)]
        _keycloakInstance = _keycloakInstance
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
        _keycloakInstance = _keycloakInstance
        _name = "${_managedResourcePrefix}provider-group-mapper"
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
        _managedResourceName = "${_managedResourcePrefix}admin"
        _projectName = _claimNamespace
        _uses = [
            kcUserGroupsWrapper.managedResource
            #providerConfigKcClientDefaultScopes.managedResource
        ]
    }

    _providerConfigCredentialsSecretName: str = core.argoCdProviderConfigSecretName(_claimNamespace, _argoCdInstance)
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
        _argoCdInstance = _argoCdInstance
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectName = _claimNamespace
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }
    argoCdInstanceCluster: core.ArgoCdClusterWrapper {
        _argoCdInstance = _argoCdInstance
        _argoCdClusterKubeconfigSecretKey= "value"
        _argoCdClusterKubeconfigSecretName = core.k8sProviderConfigSecretName(_claimNamespace, "ctrl")
        _argoCdClusterKubeconfigSecretNamespace = _claimNamespace
        _argoCdClusterName = "instance-cluster"
        _projectName= _claimNamespace
        _resourceName: "${_managedResourcePrefix}instance-cluster"
    }
    managedResources: [core.ManagedResource | core.ArgoCdProviderConfig] = [
        kcArgoCdClient.managedResource
        kcArgoCdAdminsGroup.managedResource
        kcArgoCdClientGroupMapper.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        argoCdDefaultProject.managedResource
        providerConfigKcClient.managedResource
        kcUserGroupsWrapper.managedResource
        groupsMapper.managedResource
        providerConfigHttpJwtToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        argoCdInstanceCluster.managedResource
    ]
    usages: [core.Usage] = sum([
        kcArgoCdClient.usages
        kcArgoCdAdminsGroup.usages
        kcArgoCdClientGroupMapper.usages
        helmRepo.usages
        helmRelease.usages
        argoCdDefaultProject.usages
        providerConfigKcClient.usages
        kcUserGroupsWrapper.usages
        groupsMapper.usages
        providerConfigHttpJwtToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        argoCdInstanceCluster.usages
    ], [])


    check:
        len(managedResources) == len({managedResource.metadata.name: True for managedResource in managedResources}), "Names of managed Resources must be unique"