schema K8sCapiMachineDeploymentWrapper:
    _name: str

    _autoscalingMinSize: int
    _autoscalingMaxSize: int
    _cluster: K8sCapiClusterWrapper
    _workerKubeadmConfigTemplate: K8sCapiKubeadmConfigTemplateWrapper
    _workerMachineTemplate: K8sCapiOsMachineTemplateWrapper
    _k8sVersion: str
    _tenantNamespace: str
    _controlPlaneK8sProviderConfigName: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec.forProvider.manifest = {
            apiVersion = "cluster.x-k8s.io/v1beta1"
            kind = "MachineDeployment"
            metadata.annotations = {
                "cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size" = str(_autoscalingMinSize)
                "cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size" = str(_autoscalingMaxSize)
            }
            metadata.name = _name
            metadata.namespace = _tenantNamespace
            spec = {
                clusterName = _cluster.managedResource.metadata.name
                selector.matchLabels = None
                template.spec = {
                    bootstrap.configRef = {
                        apiVersion = "bootstrap.cluster.x-k8s.io/v1beta1"
                        kind = "KubeadmConfigTemplate"
                        name = _workerKubeadmConfigTemplate.managedResource.metadata.name
                    }
                    clusterName = _cluster.managedResource.metadata.name
                    failureDomain = "nova"
                    infrastructureRef = {
                        apiVersion = "infrastructure.cluster.x-k8s.io/v1beta1"
                        kind = "OpenStackMachineTemplate"
                        name = _workerMachineTemplate.managedResource.metadata.name
                    }
                    nodeDrainTimeout = "60s"
                    version = _k8sVersion
                }
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = []

