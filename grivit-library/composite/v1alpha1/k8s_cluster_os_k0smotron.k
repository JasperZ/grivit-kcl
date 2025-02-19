import crypto
import core.v1alpha1 as core

schema K8sClusterOsK0smotronConfigWorkersAutoscaling:
    minSize: int
    maxSize: int

schema K8sClusterOsK0smotronConfigWorkers:
    flavorName: str
    rootVolumeSize: int
    autoscaling: K8sClusterOsK0smotronConfigWorkersAutoscaling

schema K8sClusterOsK0smotronConfigControlPlane:
    flavorName: str
    rootVolumeSize: int
    replicas: int

schema K8sClusterOsK0smotron:
    # _argoCdDomain: str
    _controlPlane: K8sClusterOsK0smotronConfigControlPlane
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneHelmProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _domain: str
    _email: str
    _headlampDomain: str
    _externalNetworkName: str
    _k8sVersion: str
    _name: str
    _observedComposedResources: any
    # _realmId: str
    # _targetKcProviderConfigWrapper: core.KcProviderConfigWrapper
    _targetOsProviderConfigName: str
    _tenantNamespace: str
    _workers: K8sClusterOsK0smotronConfigWorkers

    applicationCredential: core.OsIdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _tenantNamespace = _tenantNamespace
        _targetOsProviderConfigName = _targetOsProviderConfigName
    }
    keypair: core.OsComputeKeypairWrapper {
        _name = "${_name}-keypair"
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    cloudConfig: core.K8sObjectSecretWrapper {
        _name = "${_name}-cloud-config"
        _secretName = "${_name}-cloud-config"
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _stringData = {
            "clouds.yaml": """\
clouds:
  openstack:
    auth:
      auth_url: https://test.grivit.cloud:5000
      auth_type: v3applicationcredential
      application_credential_id: ${applicationCredential.getApplicationCredentialId(_observedComposedResources)}
      application_credential_secret: ${applicationCredential.getApplicationCredentialSecret(_observedComposedResources)}
      project_id: 48f988d765c6418e92ad153a9bfcb5a4
      project_name: "os.grivit.cust.jasper.dev"
      user_domain_name: "Default"
      region_name: "RegionOne"
      interface: "public"
      identity_api_version: 3
"""
        }
        _targetNamespace = _tenantNamespace
        _uses = [applicationCredential.managedResource]
    }
    controlPlaneWrapper: core.K8sCapiK0smotronControlPlaneWrapper {
        _name = "${_name}-ctl-plane-kubeadm"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _k8sVersion = _k8sVersion
        _replicas = _controlPlane.replicas
        _tenantNamespace = _tenantNamespace
    }
    openstackCluster: core.K8sCapiOsClusterWrapper {
        _name = "${_name}-os-cluster"
        _cloudConfigName = cloudConfig.managedResource.metadata.name
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _externalNetworkName = _externalNetworkName
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.metadata.annotations = {
            "cluster.x-k8s.io/managed-by" = "k0smotron"
        }
    }
    cluster: core.K8sCapiClusterWrapper {
        _name = "${_name}-cluster"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _capiControlPlaneWrapper = controlPlaneWrapper
        _capiInfrastructureWrapper = openstackCluster
        _tenantNamespace = _tenantNamespace
        _uses = [cloudConfig.managedResource]
    }
    workerConfigTemplate: core.K8sCapiK0smotronWorkerConfigTemplateWrapper {
        _name = "${_name}-worker-kubeadm-template"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
        # _k8sVersion = _k8sVersion
    }
    _workerMachineKubernetesVersion = _k8sVersion
    _workerMachineTemplateFlavorName = str(_workers.flavorName)
    _workerMachineTemplateImageName = "ubuntu-22.04-20240821"
    _workerMachineTemplateRootVolumeSize = int(_workers.rootVolumeSize)
    _workerMachineTemplateHash = str(crypto.sha256("${_workerMachineTemplateFlavorName},${_workerMachineTemplateImageName},${_workerMachineTemplateRootVolumeSize}"))[:8:]
    workerMachineTemplate: core.K8sCapiOsMachineTemplateWrapper {
        _name = "${_name}-worker-machine-template-${_workerMachineTemplateHash}"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _flavor = _workerMachineTemplateFlavorName
        _imageName = _workerMachineTemplateImageName
        _keypairName = keypair.managedResource.metadata.name
        _rootVolumeSize = _workerMachineTemplateRootVolumeSize
        _tenantNamespace = _tenantNamespace
        _uses = [keypair.managedResource]
    }
    workerMachineDeployment: core.K8sCapiMachineDeploymentWrapper {
        _name = "${_name}-worker-machine-deployment"
        _autoscalingMinSize = _workers.autoscaling.minSize
        _autoscalingMaxSize = _workers.autoscaling.maxSize
        _cluster = cluster
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _configTemplateWrapper = workerConfigTemplate
        _machineTemplateWrapper = workerMachineTemplate
        _k8sVersion = _workerMachineKubernetesVersion
        _tenantNamespace = _tenantNamespace
    }
    providerConfig: core.K8sProviderConfigWrapper {
        _name = "${_name}-provider-config"
        _credentialsSecretName = "${cluster.managedResource.metadata.name}-kubeconfig"
        _credentialsSecretNamespace = _tenantNamespace
        _uses = [
            cluster.managedResource
            openstackCluster.managedResource
            controlPlaneWrapper.managedResource
        ]
    }
    k8sCRDsBundle: K8sAppBundleCrds {
        _clusterName = _name
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = providerConfig
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsInfrastructureOsBundle: K8sAppBundleOsInfrastructure {
        _clusterName = cluster.managedResource.metadata.name
        _clusterSubnetId = openstackCluster.getSubnetId(_observedComposedResources)
        _controlPlaneHelmProviderConfigName = _controlPlaneHelmProviderConfigName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _domainFilters = [_domain]
        _externalNetworkId = openstackCluster.getExternalNetworkId(_observedComposedResources)
        _fluxHelmReleaseDependencies = k8sCRDsBundle.fluxHelmReleases
        _name = "${_name}-ia"
        _observedComposedResources = _observedComposedResources
        _targetK8sProviderConfig = providerConfig
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformBundle: K8sAppBundlePlatform {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _email = _email
        _fluxHelmReleaseDependencies = k8sAppsInfrastructureOsBundle.fluxHelmReleases
        _name = "${_name}-pa"
        _observedComposedResources = _observedComposedResources
        _targetK8sProviderConfig = providerConfig
        _tenantNamespace = _tenantNamespace
    }
#     kcArgoCdClient: core.KcOpenIdClientWrapper {
#         _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
#         _clientId = "${_name}-argocd"
#         _name = "${_name}-argocd-client"
#         _realmId = _realmId
#         _redirectUri = "https://${_argoCdDomain}/auth/callback"
#         _url = "https://${_argoCdDomain}"
#     }
#     kcArgoCdClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
#         _additionalScopes = ["groups"]
#         _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
#         _clientId = kcArgoCdClient.getAtProviderId(_observedComposedResources)
#         _name = "${_name}-argocd-client-default-scopes"
#         _realmId = _realmId
#     }
#     k8sAppsOperationArgoCd: K8sAppOperationsArgoCd {
#         _name = "${_name}-oa-argocd"
#         _domain = _argoCdDomain
#         _fluxHelmReleaseDependencies = k8sAppsInfrastructureOsBundle.fluxHelmReleases
#         _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
#         _targetK8sProviderConfig = providerConfig
#         _tenantNamespace = _tenantNamespace
#         helmRelease.managedResource.spec.forProvider.manifest.spec.values.configs.cm = {
#             "oidc.config" = """\
# name: Keycloak
# issuer: https://keycloak.hub.test.grivit.com/realms/${_realmId}
# clientID: ${kcArgoCdClient.managedResource.spec.forProvider.clientId}
# clientSecret: ${kcArgoCdClient.getClientSecret(_observedComposedResources)}
# requestedScopes: ["openid", "profile", "email", "groups"]
# """
#         }
#         helmRelease.managedResource.spec.forProvider.manifest.spec.values.configs.rbac = {
#             "policy.csv" = """\
# p, role:authenticated, *, *, *, deny

# g, admin, role:admin
# g, viewer, role:readonly
# """
#             "policy.default" = "role:authenticated"
#             scopes = "[groups]"
#         }
#     }
    managedResources: [core.K8sProviderConfig | core.ManagedResource] = [
        applicationCredential.managedResource
        cluster.managedResource
        cloudConfig.managedResource
        controlPlaneWrapper.managedResource
        keypair.managedResource
        openstackCluster.managedResource
        workerConfigTemplate.managedResource
        workerMachineDeployment.managedResource
        workerMachineTemplate.managedResource
        providerConfig.managedResource
        # kcArgoCdClient.managedResource
        # kcArgoCdClientDefaultScopes.managedResource
    ] + sum([
        k8sCRDsBundle.managedResources
        k8sAppsInfrastructureOsBundle.managedResources
        k8sAppsPlatformBundle.managedResources
        # k8sAppsOperationArgoCd.managedResources
    ], [])

    usages: [core.Usage] = sum([
        applicationCredential.usages
        cluster.usages
        cloudConfig.usages
        controlPlaneWrapper.usages
        keypair.usages
        openstackCluster.usages
        workerConfigTemplate.usages
        workerMachineDeployment.usages
        workerMachineTemplate.usages
        providerConfig.usages
        k8sCRDsBundle.usages
        k8sAppsInfrastructureOsBundle.usages
        k8sAppsPlatformBundle.usages
        # k8sAppsOperationArgoCd.usages
        # kcArgoCdClient.usages
        # kcArgoCdClientDefaultScopes.usages
    ], [])

