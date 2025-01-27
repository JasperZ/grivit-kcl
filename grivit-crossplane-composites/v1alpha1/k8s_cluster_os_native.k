import base64
import crypto
import api.cp.core.v1 as cpCore
import api.cp.k8s.app.v1 as cpK8sApp
import api.cp.k8s.appbundle.v1 as cpK8sAppbundle
import api.cp.k8s.capi.v1 as cpK8sCapi
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.kc.v1 as cpKc
import api.cp.os.v1 as cpOs

schema K8sClustersOsNativeConfigWorkersAutoscaling:
    minSize: int
    maxSize: int

schema K8sClustersOsNativeConfigWorkers:
    flavorName: str
    rootVolumeSize: int
    autoscaling: K8sClustersOsNativeConfigWorkersAutoscaling

schema K8sClustersOsNativeConfigControlPlane:
    flavorName: str
    rootVolumeSize: int
    replicas: int

schema K8sClustersOsNative:
    _argoCdDomain: str
    _controlPlane: K8sClustersOsNativeConfigControlPlane
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneHelmProviderConfigName: str
    _controlPlaneKcProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _domain: str
    _headlampDomain: str
    _externalNetworkName: str
    _k8sVersion: str
    _name: str
    _observedCompositeResource: any
    _realmId: str
    _targetOsProviderConfigName: str
    _tenantNamespace: str
    _workers: K8sClustersOsNativeConfigWorkers

    applicationCredential: cpOs.IdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _tenantNamespace = _tenantNamespace
        _targetOsProviderConfigName = _targetOsProviderConfigName
    }
    keypair: cpOs.ComputeKeypairWrapper {
        _name = "${_name}-keypair"
        _targetOsProviderConfigName = _targetOsProviderConfigName
    }
    # ToDo: url, project_id & project_name hardcoded
    _appCredId = None
    _appCredSecret = None
    _appCredName: str = applicationCredential.managedResource.metadata.name
    if _appCredName in _observedCompositeResource:
        _appCredId = str(_observedCompositeResource[_appCredName].Resource?.status?.atProvider?.id or "")
        _appCredSecret = base64.decode(_observedCompositeResource[_appCredName].ConnectionDetails["attribute.secret"])

    cloudConfig: cpK8sCore.ObjectSecretWrapper {
        _name = "${_name}-cloud-config"
        _targetK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _stringData = {
            "clouds.yaml": """\ 
clouds:
  openstack:
    auth:
      auth_url: https://test.grivit.cloud:5000
      auth_type: v3applicationcredential
      application_credential_id: ${_appCredId}
      application_credential_secret: ${_appCredSecret}
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
    _controlPlaneMachineTemplateFlavorName = str(_controlPlane.flavorName)
    _controlPlaneMachineTemplateImageName = str("ubuntu-2204-kube-${_k8sVersion}")
    _controlPlaneMachineTemplateRootVolumeSize = int(_controlPlane.rootVolumeSize)
    _controlPlaneMachineTemplateHash = str(crypto.sha256("${_controlPlaneMachineTemplateFlavorName},${_controlPlaneMachineTemplateImageName},${_controlPlaneMachineTemplateRootVolumeSize}"))[:8:]
    controlPlaneMachineTemplate: cpK8sCapi.OsMachineTemplateWrapper {
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _flavor = _controlPlaneMachineTemplateFlavorName
        _name = "${_name}-ctl-plane-machine-template-${_controlPlaneMachineTemplateHash}"
        _imageName = _controlPlaneMachineTemplateImageName
        _keypairName = keypair.managedResource.metadata.name
        _rootVolumeSize = _controlPlaneMachineTemplateRootVolumeSize
        _tenantNamespace = _tenantNamespace
        _uses = [keypair.managedResource]
    }
    controlPlaneKubeadm: cpK8sCapi.KubeadmControlPlaneWrapper {
        _name = "${_name}-ctl-plane-kubeadm"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _controlPlaneMachineTemplate = controlPlaneMachineTemplate
        _k8sVersion = _k8sVersion
        _replicas = _controlPlane.replicas
        _tenantNamespace = _tenantNamespace
    }
    openstackCluster: cpK8sCapi.OsClusterWrapper {
        _name = "${_name}-os-cluster"
        _cloudConfigName = cloudConfig.managedResource.metadata.name
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _externalNetworkName = _externalNetworkName
        _tenantNamespace = _tenantNamespace
    }
    cluster: cpK8sCapi.ClusterWrapper {
        _name = "${_name}-cluster"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _controlPlaneKubeadm = controlPlaneKubeadm
        _openstackCluster = openstackCluster
        _tenantNamespace = _tenantNamespace
        _uses = [cloudConfig.managedResource]
    }
    workerKubeadmConfigTemplate: cpK8sCapi.KubeadmConfigTemplateWrapper {
        _name = "${_name}-worker-kubeadm-template"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    _workerMachineKubernetesVersion = _observedCompositeResource[controlPlaneKubeadm.managedResource.metadata.name].Resource?.status?.atProvider?.manifest?.status?.version or ""
    _workerMachineTemplateFlavorName = str(_workers.flavorName)
    _workerMachineTemplateImageName = str("ubuntu-2204-kube-${_workerMachineKubernetesVersion}")
    _workerMachineTemplateRootVolumeSize = int(_workers.rootVolumeSize)
    _workerMachineTemplateHash = str(crypto.sha256("${_workerMachineTemplateFlavorName},${_workerMachineTemplateImageName},${_workerMachineTemplateRootVolumeSize}"))[:8:]
    workerMachineTemplate: cpK8sCapi.OsMachineTemplateWrapper {
        _name = "${_name}-worker-machine-template-${_workerMachineTemplateHash}"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _flavor = _workerMachineTemplateFlavorName
        _imageName = _workerMachineTemplateImageName
        _keypairName = keypair.managedResource.metadata.name
        _rootVolumeSize = _workerMachineTemplateRootVolumeSize
        _tenantNamespace = _tenantNamespace
        _uses = [keypair.managedResource]
    }
    workerMachineDeployment: cpK8sCapi.MachineDeploymentWrapper {
        _name = "${_name}-worker-machine-deployment"
        _autoscalingMinSize = _workers.autoscaling.minSize
        _autoscalingMaxSize = _workers.autoscaling.maxSize
        _cluster = cluster
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _workerKubeadmConfigTemplate = workerKubeadmConfigTemplate
        _workerMachineTemplate = workerMachineTemplate
        _k8sVersion = _workerMachineKubernetesVersion
        _tenantNamespace = _tenantNamespace
    }
    providerConfig: cpK8sCore.ProviderConfigWrapper {
        _name = "${_name}-provider-config"
        _credentialsSecretName = "${cluster.managedResource.metadata.name}-kubeconfig"
        _credentialsSecretNamespace = _tenantNamespace
        _uses = [
            cluster.managedResource
            openstackCluster.managedResource
            controlPlaneKubeadm.managedResource
            controlPlaneMachineTemplate.managedResource
        ]
    }
    k8sCRDsBundle: cpK8sAppbundle.Crds {
        _clusterName = _name
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = providerConfig
        _tenantNamespace = _tenantNamespace
    }
    _clusterSubnetId: str = ""
    _externalNetworkId: str = ""
    _osClusterName: str = openstackCluster.managedResource.metadata.name
    if _observedCompositeResource[_osClusterName].Resource?.status?.atProvider?.manifest?.status?.network?.subnets and len(_observedCompositeResource[_osClusterName].Resource.status.atProvider.manifest.status.network.subnets) > 0:
        _clusterSubnetId = _observedCompositeResource[_osClusterName].Resource.status.atProvider.manifest.status.network.subnets[0].id

    if _observedCompositeResource[_osClusterName].Resource?.status?.atProvider?.manifest?.status?.externalNetwork?.id:
        _externalNetworkId = _observedCompositeResource[_osClusterName].Resource.status.atProvider.manifest.status.externalNetwork.id

    k8sAppsInfrastructureOsBundle: cpK8sAppbundle.OsInfrastructure {
        _clusterName = cluster.managedResource.metadata.name
        _clusterSubnetId = _clusterSubnetId
        _controlPlaneHelmProviderConfigName = _controlPlaneHelmProviderConfigName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _domainFilters = [_domain]
        _externalNetworkId = _externalNetworkId
        _fluxHelmReleaseDependencies = k8sCRDsBundle.fluxHelmReleases
        _name = "${_name}-ia"
        _observedCompositeResource = _observedCompositeResource
        _targetK8sProviderConfig = providerConfig
        _targetOsProviderConfigName = _targetOsProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    k8sAppsPlatformBundle: cpK8sAppbundle.Platform {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _fluxHelmReleaseDependencies = k8sAppsInfrastructureOsBundle.fluxHelmReleases
        _name = "${_name}-pa"
        _observedCompositeResource = _observedCompositeResource
        _targetK8sProviderConfig = providerConfig
        _tenantNamespace = _tenantNamespace
    }
    kcArgoCdClient: cpKc.OpenIdClientWrapper {
        _controlPlaneKcProviderConfigName = _controlPlaneKcProviderConfigName
        _connectionSecretName = "${_name}-argocd-client-conn"
        _connectionSecretNamespace = _tenantNamespace
        _clientId = "${_name}-argocd"
        _name = "${_name}-argocd-client"
        _realmId = _realmId
        _redirectUri = "https://${_argoCdDomain}/auth/callback"
        _url = "https://${_argoCdDomain}"
    }
    _kcArgoCdClientId = None
    _kcArgoCdClientSecret = None
    _kcArgoCdClientName: str = kcArgoCdClient.managedResource.metadata.name
    if _kcArgoCdClientName in _observedCompositeResource:
        _kcArgoCdClientId = str(_observedCompositeResource[_kcArgoCdClientName].Resource?.status?.atProvider?.id or "")
        _kcArgoCdClientSecret = base64.decode(_observedCompositeResource[_kcArgoCdClientName].ConnectionDetails["attribute.client_secret"])

    kcArgoCdClientDefaultScopes: cpKc.OpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _controlPlaneKcProviderConfigName = _controlPlaneKcProviderConfigName
        _clientId = _kcArgoCdClientId
        _name = "${_name}-argocd-client-default-scopes"
        _realmId = _realmId
    }
    k8sAppsOperationArgoCd: cpK8sApp.OperationArgoCd {
        _name = "${_name}-oa-argocd"
        _domain = _argoCdDomain
        _fluxHelmReleaseDependencies = k8sAppsInfrastructureOsBundle.fluxHelmReleases
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = providerConfig
        _tenantNamespace = _tenantNamespace
        helmRelease.managedResource.spec.forProvider.manifest.spec.values.configs.cm = {
            "oidc.config" = """\
name: Keycloak
issuer: https://keycloak.hub.test.grivit.com/realms/${_realmId}
clientID: ${kcArgoCdClient.managedResource.spec.forProvider.clientId}
clientSecret: ${_kcArgoCdClientSecret}
requestedScopes: ["openid", "profile", "email", "groups"]
"""
        }
        helmRelease.managedResource.spec.forProvider.manifest.spec.values.configs.rbac = {
            "policy.csv" = """\
p, role:authenticated, *, *, *, deny

g, admin, role:admin
g, viewer, role:readonly
"""
            "policy.default" = "role:authenticated"
            scopes = "[groups]"
        }
    }
    managedResources: [cpK8sCore.ProviderConfig | cpCore.ManagedResource] = [
        applicationCredential.managedResource
        cluster.managedResource
        cloudConfig.managedResource
        controlPlaneKubeadm.managedResource
        controlPlaneMachineTemplate.managedResource
        keypair.managedResource
        openstackCluster.managedResource
        workerKubeadmConfigTemplate.managedResource
        workerMachineDeployment.managedResource
        workerMachineTemplate.managedResource
        providerConfig.managedResource
        kcArgoCdClient.managedResource
        kcArgoCdClientDefaultScopes.managedResource
    ] + k8sCRDsBundle.managedResources + k8sAppsInfrastructureOsBundle.managedResources + k8sAppsPlatformBundle.managedResources + k8sAppsOperationArgoCd.managedResources

    usages: [cpCore.Usage] = applicationCredential.usages + cluster.usages + cloudConfig.usages + controlPlaneKubeadm.usages + controlPlaneMachineTemplate.usages + keypair.usages + openstackCluster.usages + workerKubeadmConfigTemplate.usages + workerMachineDeployment.usages + workerMachineTemplate.usages + providerConfig.usages + k8sCRDsBundle.usages + k8sAppsInfrastructureOsBundle.usages + k8sAppsPlatformBundle.usages + k8sAppsOperationArgoCd.usages + kcArgoCdClient.usages + kcArgoCdClientDefaultScopes.usages

