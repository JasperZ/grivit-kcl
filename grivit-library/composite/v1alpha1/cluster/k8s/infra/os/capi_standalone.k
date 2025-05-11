import crypto
import core.v1alpha1 as core

import .....k8s.app.certmanager as certmanager

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
    _argoCdInstance: core.ArgoCdInstance
    _clusterName: str
    _controlPlane: CapiStandaloneClusterK8sInfraOsConfigControlPlane
    _composite: str
    _domain: str
    _email: str
    _externalNetworkName: str
    _k8sVersion: str
    _name: str
    _observedComposedResources: any
    _claimNamespace: str
    _claimName: str
    _workers: CapiStandaloneClusterK8sInfraOsConfigWorkers

    _managedResourcePrefix: str = _claimName + "-"
    _managedResourceSuffix: str = ""

    applicationCredential: core.OsIdentityApplicationCredentialWrapper {
        _name = "${_managedResourcePrefix}os-app-cred${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
    }
    keypair: core.OsComputeKeypairWrapper {
        _name = "${_managedResourcePrefix}os-keypair${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
    }
    cloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "${_managedResourcePrefix}cloud-config-secret${_managedResourceSuffix}"
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = "${_managedResourcePrefix}cloud-config-secret${_managedResourceSuffix}"
        _stringData = {
            "clouds.yaml": """\
clouds:
  openstack:
    auth:
      auth_url: https://test.grivit.cloud:5000
      auth_type: v3applicationcredential
      application_credential_id: ${applicationCredential.getApplicationCredentialId(_observedComposedResources)}
      application_credential_secret: ${applicationCredential.getApplicationCredentialSecret(_observedComposedResources)}
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
        _name = "${_managedResourcePrefix}capi-ctrl-mach-tpl-${_controlPlaneMachineTemplateHash}${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
        _rootVolumeSize = _controlPlaneMachineTemplateRootVolumeSize
        _uses = [keypair.managedResource]
    }
    controlPlaneKubeadm: core.K8sCapiKubeadmControlPlaneWrapper {
        _controlPlaneMachineTemplate = controlPlaneMachineTemplate
        _k8sVersion = _k8sVersion
        _name = "${_managedResourcePrefix}capi-ctl-plane-kubeadm${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
        _replicas = _controlPlane.replicas
    }
    openstackCluster: core.K8sCapiOsClusterWrapper {
        _cloudConfigName = cloudConfig.managedResource.metadata.name
        _externalNetworkName = _externalNetworkName
        _name = "${_managedResourcePrefix}capi-os-cluster${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
    }
    cluster: core.K8sCapiClusterWrapper {
        _capiControlPlaneWrapper = controlPlaneKubeadm
        _capiInfrastructureWrapper = openstackCluster
        _name = "${_managedResourcePrefix}capi-cluster${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
        _uses = [cloudConfig.managedResource]
    }
    workerKubeadmConfigTemplate: core.K8sCapiKubeadmWorkerConfigTemplateWrapper {
        _name = "${_managedResourcePrefix}capi-kubeadm-worker-template${_managedResourceSuffix}"
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
        _name = "${_managedResourcePrefix}capi-wrk-mach-tpl-${_workerMachineTemplateHash}${_managedResourceSuffix}"
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
        _name = "${_managedResourcePrefix}capi-wrk-mach-depl${_managedResourceSuffix}"
        _projectNamespace = _claimNamespace
    }
    k8sProviderConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = core.k8sProviderConfigSecretName(_claimNamespace, _clusterName)
        _namespace = _claimNamespace
        _projectName = _claimNamespace
        _secretName = core.k8sProviderConfigSecretName(_claimNamespace, _clusterName)
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
        _clusterName = _clusterName
        _credentialsSecretName = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = k8sProviderConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _projectNamespace = _claimNamespace
        _uses = [
            k8sProviderConfigCredentialsSecret.managedResource
        ]
    }
    externalDnsCloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = "${_managedResourcePrefix}ext-sec-cloud-conf${_managedResourceSuffix}"
        _namespace = "kube-system"
        _projectName = _claimNamespace
        _secretName = "external-dns-openstack-clouds-config"
        _stringData = {
            "clouds.yaml": """\
clouds:
  openstack:
    auth:
      application_credential_id: "${applicationCredential.getApplicationCredentialId(_observedComposedResources)}"
      application_credential_secret: "${applicationCredential.getApplicationCredentialSecret(_observedComposedResources)}"
      auth_url: "https://test.grivit.cloud:5000"
      auth_type: "v3applicationcredential"
      interface: "public"
      region_name: "RegionOne"
"""
        }
        _uses = [providerConfig.managedResource]
    }
    openstackCinderCsiCloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = "${_managedResourcePrefix}cinder-csi-cloud-conf${_managedResourceSuffix}"
        _namespace = "kube-system"
        _projectName = _claimNamespace
        _secretName = "openstack-cinder-csi-cloud-config"
        _stringData = {
            "cloud.conf": """\
[Global]
application-credential-id = "${applicationCredential.getApplicationCredentialId(_observedComposedResources)}"
application-credential-secret = "${applicationCredential.getApplicationCredentialSecret(_observedComposedResources)}"
auth-url = "https://test.grivit.cloud:5000"
"""
        }
        _uses = [providerConfig.managedResource]
    }
    openstackCloudControllerManagerCloudConfig: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = "${_managedResourcePrefix}occm-cloud-conf${_managedResourceSuffix}"
        _namespace = "kube-system"
        _projectName = _claimNamespace
        _secretName = "openstack-cloud-controller-manager-cloud-config"
        _stringData = {
            "cloud.conf": """\
[Global]
application-credential-id = "${applicationCredential.getApplicationCredentialId(_observedComposedResources)}"
application-credential-secret = "${applicationCredential.getApplicationCredentialSecret(_observedComposedResources)}"
auth-url = "https://test.grivit.cloud:5000"

[Networking]

[LoadBalancer]
create-monitor = "true"
floating-network-id = "${openstackCluster.getExternalNetworkId(_observedComposedResources)}"
lb-method = "SOURCE_IP_PORT"
lb-provider = "ovn"
subnet-id = "${openstackCluster.getSubnetId(_observedComposedResources)}"

[BlockStorage]

[Metadata]

[Route]
"""
        }
        _uses = [providerConfig.managedResource]
    }
    argoCdCluster: core.ArgoCdClusterWrapper2 {
        _argoCdClusterKubeconfigSecretKey = "value"
        _argoCdClusterKubeconfigSecretName = "${cluster.managedResource.metadata.name}-kubeconfig"
        _argoCdClusterKubeconfigSecretNamespace = _claimNamespace
        _argoCdClusterLabels = {
            "project": _claimNamespace
        }
        _argoCdClusterName = core.argoCdClusterName(_claimNamespace, _clusterName)
        _argoCdClusterProject = _argoCdInstance.projectName
        _projectName = _claimNamespace
        _resourceName = "${_managedResourcePrefix}cluster${_managedResourceSuffix}"
        _uses = [
            cluster.managedResource
            openstackCluster.managedResource
            controlPlaneKubeadm.managedResource
            controlPlaneMachineTemplate.managedResource
        ]
    }
    certmanagerClusterIssuer: certmanager.ClusterIssuerCertManagerAppK8s {
        _clusterName = _clusterName
        _email = _email
        _name = _managedResourcePrefix
        _observedComposedResources = _observedComposedResources
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
        externalDnsCloudConfig.managedResource
        openstackCinderCsiCloudConfig.managedResource
        openstackCloudControllerManagerCloudConfig.managedResource
        argoCdCluster.managedResource
    ] + sum([
        certmanagerClusterIssuer.managedResources
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
        externalDnsCloudConfig.usages
        openstackCinderCsiCloudConfig.usages
        openstackCloudControllerManagerCloudConfig.usages
        argoCdCluster.usages
        certmanagerClusterIssuer.usages
    ], [])

    check:
        len(managedResources) == len({managedResource.metadata.name: True for managedResource in managedResources}), "Names of managed Resources must be unique"

