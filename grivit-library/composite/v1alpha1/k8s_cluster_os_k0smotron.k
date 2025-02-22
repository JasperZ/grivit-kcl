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
    _controlPlane: K8sClusterOsK0smotronConfigControlPlane
    _domain: str
    _email: str
    _externalNetworkName: str
    _k8sVersion: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str
    _workers: K8sClusterOsK0smotronConfigWorkers

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
    controlPlaneWrapper: core.K8sCapiK0smotronControlPlaneWrapper {
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
        managedResource.spec.forProvider.manifest.metadata.annotations = {
            "cluster.x-k8s.io/managed-by" = "k0smotron"
        }
    }
    cluster: core.K8sCapiClusterWrapper {
        _capiControlPlaneWrapper = controlPlaneWrapper
        _capiInfrastructureWrapper = openstackCluster
        _name = "${_name}-cluster"
        _projectNamespace = _projectNamespace
        _uses = [cloudConfig.managedResource]
    }
    workerConfigTemplate: core.K8sCapiK0smotronWorkerConfigTemplateWrapper {
        _name = "${_name}-worker-kubeadm-template"
        _projectNamespace = _projectNamespace
        # _k8sVersion = _k8sVersion
    }
    _workerMachineKubernetesVersion = _k8sVersion
    _workerMachineTemplateFlavorName = str(_workers.flavorName)
    _workerMachineTemplateImageName = "ubuntu-22.04-20240821"
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
        _configTemplateWrapper = workerConfigTemplate
        _k8sVersion = _workerMachineKubernetesVersion
        _machineTemplateWrapper = workerMachineTemplate
        _name = "${_name}-worker-machine-deployment"
        _projectNamespace = _projectNamespace
    }
    providerConfig: core.K8sProviderConfigWrapper {
        _name = "${_projectNamespace}-${_name}-config"
        _credentialsSecretName = "${cluster.managedResource.metadata.name}-kubeconfig"
        _credentialsSecretNamespace = _projectNamespace
        _uses = [
            cluster.managedResource
            openstackCluster.managedResource
            controlPlaneWrapper.managedResource
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
    ] + sum([
        k8sCRDsBundle.managedResources
        k8sAppsInfrastructureOsBundle.managedResources
        k8sAppsPlatformBundle.managedResources
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
    ], [])

