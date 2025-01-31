schema K8sCapiMachineDeploymentWrapper:
    _name: str

    _autoscalingMinSize: int
    _autoscalingMaxSize: int
    _cluster: K8sCapiClusterWrapper
    _configTemplateWrapper: K8sCapiKubeadmConfigTemplateWrapper | K8sCapiK0smotronConfigTemplateWrapper
    _machineTemplateWrapper: K8sCapiOsMachineTemplateWrapper
    _k8sVersion: str
    _tenantNamespace: str
    _controlPlaneK8sProviderConfigName: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
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
                        apiVersion = _configTemplateWrapper.managedResource.apiVersion
                        kind = _configTemplateWrapper.managedResource.kind
                        name = _configTemplateWrapper.managedResource.metadata.name
                    }
                    clusterName = _cluster.managedResource.metadata.name
                    failureDomain = "nova"
                    infrastructureRef = {
                        apiVersion = _machineTemplateWrapper.managedResource.apiVersion
                        kind = _machineTemplateWrapper.managedResource.kind
                        name = _machineTemplateWrapper.managedResource.metadata.name
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

