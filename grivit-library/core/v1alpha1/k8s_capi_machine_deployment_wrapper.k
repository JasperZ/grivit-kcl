schema K8sCapiMachineDeploymentWrapper:
    _autoscalingMaxSize: int
    _autoscalingMinSize: int
    _cluster: K8sCapiClusterWrapper
    _configTemplateWrapper: K8sCapiKubeadmWorkerConfigTemplateWrapper | K8sCapiK0smotronWorkerConfigTemplateWrapper
    _k8sVersion: str
    _machineTemplateWrapper: K8sCapiOsMachineTemplateWrapper
    _name: str
    _projectNamespace: str

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
            metadata.namespace = _projectNamespace
            spec = {
                clusterName = _cluster.managedResource.metadata.name
                selector.matchLabels = None
                template.spec = {
                    bootstrap.configRef = {
                        apiVersion = _configTemplateWrapper.managedResource.spec.forProvider.manifest.apiVersion
                        kind = _configTemplateWrapper.managedResource.spec.forProvider.manifest.kind
                        name = _configTemplateWrapper.managedResource.spec.forProvider.manifest.metadata.name
                    }
                    clusterName = _cluster.managedResource.metadata.name
                    failureDomain = "nova"
                    infrastructureRef = {
                        apiVersion = _machineTemplateWrapper.managedResource.spec.forProvider.manifest.apiVersion
                        kind = _machineTemplateWrapper.managedResource.spec.forProvider.manifest.kind
                        name = _machineTemplateWrapper.managedResource.spec.forProvider.manifest.metadata.name
                    }
                    nodeDrainTimeout = "60s"
                    version = _k8sVersion
                }
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = k8sProviderConfigName(_projectNamespace, "ctrl")
    }
    usages: [Usage] = []

    check:
        len(managedResource.metadata.name) < 64
        len(managedResource.spec.forProvider.manifest.metadata.name) < 64
