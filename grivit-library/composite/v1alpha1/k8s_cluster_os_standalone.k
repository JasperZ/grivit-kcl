import crypto
import core.v1alpha1 as core

schema K8sClusterOsStandaloneConfigWorkersAutoscaling:
    minSize: int
    maxSize: int

schema K8sClusterOsStandaloneConfigWorkers:
    flavorName: str
    rootVolumeSize: int
    autoscaling: K8sClusterOsStandaloneConfigWorkersAutoscaling

schema K8sClusterOsStandaloneConfigControlPlane:
    flavorName: str
    rootVolumeSize: int
    replicas: int

schema K8sClusterOsStandalone:
    _controlPlane: K8sClusterOsStandaloneConfigControlPlane
    _domain: str
    _email: str
    _externalNetworkName: str
    _k8sVersion: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str
    _workers: K8sClusterOsStandaloneConfigWorkers

    applicationCredential: core.OsIdentityApplicationCredentialWrapper {
        _name = "${_name}-application-credential"
        _projectNamespace = _projectNamespace
    }
    keypair: core.OsComputeKeypairWrapper {
        _name = "${_name}-keypair"
        _projectNamespace = _projectNamespace
    }
    cloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_name}-cloud-config"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "${_name}-cloud-config"
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
        _name = "${_name}-ctl-plane-machine-template-${_controlPlaneMachineTemplateHash}"
        _projectNamespace = _projectNamespace
        _rootVolumeSize = _controlPlaneMachineTemplateRootVolumeSize
        _uses = [keypair.managedResource]
    }
    controlPlaneKubeadm: core.K8sCapiKubeadmControlPlaneWrapper {
        _controlPlaneMachineTemplate = controlPlaneMachineTemplate
        _k8sVersion = _k8sVersion
        _name = "${_name}-ctl-plane-kubeadm"
        _projectNamespace = _projectNamespace
        _replicas = _controlPlane.replicas
    }
    openstackCluster: core.K8sCapiOsClusterWrapper {
        _cloudConfigName = cloudConfig.managedResource.metadata.name
        _externalNetworkName = _externalNetworkName
        _name = "${_name}-os-cluster"
        _projectNamespace = _projectNamespace
    }
    cluster: core.K8sCapiClusterWrapper {
        _capiControlPlaneWrapper = controlPlaneKubeadm
        _capiInfrastructureWrapper = openstackCluster
        _name = "${_name}-cluster"
        _projectNamespace = _projectNamespace
        _uses = [cloudConfig.managedResource]
    }
    workerKubeadmConfigTemplate: core.K8sCapiKubeadmWorkerConfigTemplateWrapper {
        _name = "${_name}-worker-kubeadm-template"
        _projectNamespace = _projectNamespace
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
        _name = "${_name}-worker-machine-template-${_workerMachineTemplateHash}"
        _projectNamespace = _projectNamespace
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
        _name = "${_name}-worker-machine-deployment"
        _projectNamespace = _projectNamespace
    }
    providerConfig: core.K8sProviderConfigWrapper {
        _name = "${_projectNamespace}-${_name}-k8s"
        _credentialsSecretName = "${cluster.managedResource.metadata.name}-kubeconfig"
        _credentialsSecretNamespace = _projectNamespace
        _uses = [
            cluster.managedResource
            openstackCluster.managedResource
            controlPlaneKubeadm.managedResource
            controlPlaneMachineTemplate.managedResource
        ]
    }
    k8sCRDsBundle: K8sAppBundleCrds {
        _clusterName = _name
        _projectNamespace = _projectNamespace
    }
    k8sAppsInfrastructureOsBundle: K8sAppBundleOsInfrastructure {
        _clusterName = cluster.managedResource.metadata.name
        _clusterSubnetId = openstackCluster.getSubnetId(_observedComposedResources)
        _domainFilters = [_domain]
        _externalNetworkId = openstackCluster.getExternalNetworkId(_observedComposedResources)
        _fluxHelmReleaseDependencies = k8sCRDsBundle.fluxHelmReleases
        _name = "${_name}-ia"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sAppsPlatformBundle: K8sAppBundlePlatform {
        _clusterName = _name
        _email = _email
        _fluxHelmReleaseDependencies = k8sAppsInfrastructureOsBundle.fluxHelmReleases
        _name = "${_name}-pa"
        _observedComposedResources = _observedComposedResources
        _projectNamespace = _projectNamespace
    }
    k8sCrossplaneSecretsNamespace: core.K8sObjectNamespaceWrapper {
        _clusterName = _name
        _name = "${_name}-crossplane-secrets-ns"
        _namespaceName = "crossplane-secrets"
        _projectNamespace = _projectNamespace
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
        providerConfig.managedResource
        k8sCrossplaneSecretsNamespace.managedResource
    ] + sum([
        k8sCRDsBundle.managedResources
        k8sAppsInfrastructureOsBundle.managedResources
        k8sAppsPlatformBundle.managedResources
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
        providerConfig.usages
        k8sCRDsBundle.usages
        k8sAppsInfrastructureOsBundle.usages
        k8sAppsPlatformBundle.usages
        k8sCrossplaneSecretsNamespace.usages
    ], [])
