import crypto
import core.v1alpha1 as core
import .....app.k8s as apps

schema CapiStandaloneClusterK8sInfraOsConfigWorkersAutoscaling:
    minSize: int
    maxSize: int

schema CapiStandaloneClusterK8sInfraOsConfigWorkers:
    flavorName: str
    rootVolumeSize: int
    autoscaling: CapiStandaloneClusterK8sInfraOsConfigWorkersAutoscaling

schema CapiStandaloneClusterK8sInfraOsConfigControlPlane:
    flavorName: str
    rootVolumeSize: int
    replicas: int

schema CapiStandaloneClusterK8sInfraOs:
    _clusterName: str
    _controlPlane: CapiStandaloneClusterK8sInfraOsConfigControlPlane
    _domain: str
    _email: str
    _externalNetworkName: str
    _k8sVersion: str
    _name: str
    _observedComposedResources: any
    _claimNamespace: str
    _claimName: str
    _workers: CapiStandaloneClusterK8sInfraOsConfigWorkers

    _managedResourcePrefix = "g-" + crypto.md5("${_claimNamespace}-${_claimName}") + "-${_clusterName}-"

    applicationCredential: core.OsIdentityApplicationCredentialWrapper {
        _name = "${_managedResourcePrefix}os-app-cred"
        _projectNamespace = _claimNamespace
    }
    keypair: core.OsComputeKeypairWrapper {
        _name = "${_managedResourcePrefix}os-keypair"
        _projectNamespace = _claimNamespace
    }
    cloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_managedResourcePrefix}k8s-cloud-config-secret"
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = "${_managedResourcePrefix}k8s-os-cloud-config-secret"
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
        _uses = [applicationCredential.managedResource]
    }
    _controlPlaneMachineTemplateFlavorName = str(_controlPlane.flavorName)
    _controlPlaneMachineTemplateImageName = str("ubuntu-2204-kube-${_k8sVersion}")
    _controlPlaneMachineTemplateRootVolumeSize = int(_controlPlane.rootVolumeSize)
    _controlPlaneMachineTemplateHash = str(crypto.sha256("${_controlPlaneMachineTemplateFlavorName},${_controlPlaneMachineTemplateImageName},${_controlPlaneMachineTemplateRootVolumeSize}"))[:8:]
    controlPlaneMachineTemplate: core.K8sCapiOsMachineTemplateWrapper {
        _flavor = _controlPlaneMachineTemplateFlavorName
        _imageName = _controlPlaneMachineTemplateImageName
        _keypairName = keypair.managedResource.metadata.name
        _name = "${_managedResourcePrefix}capi-ctrl-machine-template-${_controlPlaneMachineTemplateHash}"
        _projectNamespace = _claimNamespace
        _rootVolumeSize = _controlPlaneMachineTemplateRootVolumeSize
        _uses = [keypair.managedResource]
    }
    controlPlaneKubeadm: core.K8sCapiKubeadmControlPlaneWrapper {
        _controlPlaneMachineTemplate = controlPlaneMachineTemplate
        _k8sVersion = _k8sVersion
        _name = "${_managedResourcePrefix}capi-ctl-plane-kubeadm"
        _projectNamespace = _claimNamespace
        _replicas = _controlPlane.replicas
    }
    openstackCluster: core.K8sCapiOsClusterWrapper {
        _cloudConfigName = cloudConfig.managedResource.metadata.name
        _externalNetworkName = _externalNetworkName
        _name = "${_managedResourcePrefix}capi-os-cluster"
        _projectNamespace = _claimNamespace
    }
    cluster: core.K8sCapiClusterWrapper {
        _capiControlPlaneWrapper = controlPlaneKubeadm
        _capiInfrastructureWrapper = openstackCluster
        _name = "${_managedResourcePrefix}capi-cluster"
        _projectNamespace = _claimNamespace
        _uses = [cloudConfig.managedResource]
    }
    workerKubeadmConfigTemplate: core.K8sCapiKubeadmWorkerConfigTemplateWrapper {
        _name = "${_managedResourcePrefix}capi-kubeadm-worker-template"
        _projectNamespace = _claimNamespace
    }
    _workerMachineKubernetesVersion = controlPlaneKubeadm.getKubernetesVersion(_observedComposedResources)
    _workerMachineTemplateFlavorName = str(_workers.flavorName)
    _workerMachineTemplateImageName = str("ubuntu-2204-kube-${_workerMachineKubernetesVersion}")
    _workerMachineTemplateRootVolumeSize = int(_workers.rootVolumeSize)
    _workerMachineTemplateHash = str(crypto.sha256("${_workerMachineTemplateFlavorName},${_workerMachineTemplateImageName},${_workerMachineTemplateRootVolumeSize}"))[:8:]
    workerMachineTemplate: core.K8sCapiOsMachineTemplateWrapper {
        _flavor = _workerMachineTemplateFlavorName
        _imageName = _workerMachineTemplateImageName
        _keypairName = keypair.managedResource.metadata.name
        _name = "${_managedResourcePrefix}capi-worker-machine-template-${_workerMachineTemplateHash}"
        _projectNamespace = _claimNamespace
        _rootVolumeSize = _workerMachineTemplateRootVolumeSize
        _uses = [keypair.managedResource]
    }
    workerMachineDeployment: core.K8sCapiMachineDeploymentWrapper {
        _autoscalingMaxSize = _workers.autoscaling.maxSize
        _autoscalingMinSize = _workers.autoscaling.minSize
        _cluster = cluster
        _configTemplateWrapper = workerKubeadmConfigTemplate
        _k8sVersion = _workerMachineKubernetesVersion
        _machineTemplateWrapper = workerMachineTemplate
        _name = "${_managedResourcePrefix}capi-worker-machine-deployment"
        _projectNamespace = _claimNamespace
    }
    k8sProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _name
        _name = core.k8sProviderConfigSecretName(_claimNamespace, _name)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.k8sProviderConfigSecretName(_claimNamespace, _name)
        _stringData = {}
        managedResource.spec.references = [
            {
                patchesFrom = {
                    apiVersion = "v1"
                    fieldPath = "data.value"
                    kind = "Secret"
                    name = "${cluster.managedResource.metadata.name}-kubeconfig"
                    namespace = _claimNamespace
                }
                toFieldPath = "data.value"
            }
        ]
        _uses = [
            cluster.managedResource
            openstackCluster.managedResource
            controlPlaneKubeadm.managedResource
            controlPlaneMachineTemplate.managedResource
        ]
    }
    providerConfig: core.K8sProviderConfigWrapper {
        _clusterName = _name
        _credentialsSecretName = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectNamespace = _claimNamespace
        _uses = [
            k8sProviderConfigCredentialsSecret.managedResource
        ]
    }
    appPrometheusOperatorCrds: apps.PrometheusOperatorCrdsAppK8s {
        _clusterName = _name
        _name = "${_managedResourcePrefix}prom-crds"
        _projectNamespace = _claimNamespace
    }
    crdAppHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        appPrometheusOperatorCrds.helmRelease
    ]
    appCilium: apps.CiliumAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _fluxHelmReleaseDependencies = crdAppHelmReleases
        _name = "${_managedResourcePrefix}cilium"
        _projectNamespace = _claimNamespace
    }
    appOpenStackCloudControllerManager: apps.OpenStackCloudControllerManagerAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _clusterSubnetId = openstackCluster.getSubnetId(_observedComposedResources)
        _externalNetworkId = openstackCluster.getExternalNetworkId(_observedComposedResources)
        _fluxHelmReleaseDependencies = crdAppHelmReleases
        _name = "${_managedResourcePrefix}occm"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    appOpenStackCinderCsi: apps.OpenStackCinderCsiAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _name = "${_managedResourcePrefix}cinder-csi"
        _fluxHelmReleaseDependencies = crdAppHelmReleases
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    appOpenStackExternalDns: apps.OpenStackExternalDnsAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _domainFilters = [_domain]
        _fluxHelmReleaseDependencies = crdAppHelmReleases
        _name = "${_managedResourcePrefix}external-dns"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    # appClusterAutoscaler: apps.ClusterAutoscalerAppK8s {
    #     _clusterName = cluster.managedResource.metadata.name
    #     _name = "${cluster.managedResource.metadata.name}-ca"
    #     _projectNamespace = _claimNamespace
    # }
    infrastructureAppHelmReleases: [core.K8sFluxHelmReleaseWrapper] = [
        appCilium.helmRelease
        appOpenStackCloudControllerManager.helmRelease
        appOpenStackCinderCsi.helmRelease
        appOpenStackExternalDns.helmRelease
    ]
    appsPlatformCertManager: apps.CertManagerAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _email: _email
        _fluxHelmReleaseDependencies = infrastructureAppHelmReleases
        _name = "${_managedResourcePrefix}certmanager"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _claimNamespace
    }
    appsPlatformIngressNginx: apps.IngressNginxAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _name = "${_managedResourcePrefix}ingress-nginx"
        _fluxHelmReleaseDependencies = infrastructureAppHelmReleases
        _projectNamespace = _claimNamespace
    }
    appsPlatformMetricsServer: apps.MetricsServerAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _name = "${_managedResourcePrefix}metrics"
        _fluxHelmReleaseDependencies = infrastructureAppHelmReleases
        _projectNamespace = _claimNamespace
    }
    appsPlatformSnapshotController: apps.SnapshotControllerAppK8s {
        _clusterName = cluster.managedResource.metadata.name
        _name = "${_managedResourcePrefix}snaphot-controller"
        _projectNamespace = _claimNamespace
    }
    k8sCrossplaneSecretsNamespace: core.K8sObjectNamespaceWrapper {
        _clusterName = _name
        _name = "${_managedResourcePrefix}k8s-ns-crossplane-secrets"
        _namespaceName = "crossplane-secrets"
        _projectNamespace = _claimNamespace
    }
    managedResources: [core.K8sProviderConfig | core.ManagedResource] = [
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
        k8sProviderConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        k8sCrossplaneSecretsNamespace.managedResource
    ] + sum([
        appPrometheusOperatorCrds.managedResources
        appCilium.managedResources
        appOpenStackCloudControllerManager.managedResources
        appOpenStackCinderCsi.managedResources
        appOpenStackExternalDns.managedResources
        # appClusterAutoscaler.managedResources
        appsPlatformCertManager.managedResources
        appsPlatformIngressNginx.managedResources
        appsPlatformMetricsServer.managedResources
        appsPlatformSnapshotController.managedResources
    ], [])
    usages: [core.Usage] = sum([
        applicationCredential.usages
        cluster.usages
        cloudConfig.usages
        controlPlaneKubeadm.usages
        controlPlaneMachineTemplate.usages
        keypair.usages
        openstackCluster.usages
        workerKubeadmConfigTemplate.usages
        workerMachineDeployment.usages
        workerMachineTemplate.usages
        k8sProviderConfigCredentialsSecret.usages
        providerConfig.usages
        appPrometheusOperatorCrds.usages
        appCilium.usages
        appOpenStackCloudControllerManager.usages
        appOpenStackCinderCsi.usages
        appOpenStackExternalDns.usages
        # appClusterAutoscaler.usages
        appsPlatformCertManager.usages
        appsPlatformIngressNginx.usages
        appsPlatformMetricsServer.usages
        appsPlatformSnapshotController.usages
        k8sCrossplaneSecretsNamespace.usages
    ], [])
