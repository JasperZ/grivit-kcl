schema K8sCapiKubeadmControlPlaneWrapper:
    _controlPlaneMachineTemplate: K8sCapiOsMachineTemplateWrapper
    _k8sVersion: str
    _name: str
    _projectNamespace: str
    _replicas: int

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.manifest = {
            apiVersion = "controlplane.cluster.x-k8s.io/v1beta1"
            kind = "KubeadmControlPlane"
            metadata.name = _name
            metadata.namespace = _projectNamespace
            spec = {
                kubeadmConfigSpec = {
                    clusterConfiguration.apiServer.extraArgs = {
                        "cloud-provider" = "external"
                    }
                    clusterConfiguration.controllerManager.extraArgs = {
                        "cloud-provider" = "external"
                    }
                    files = [
                        {
                            path = "/etc/containerd/certs.d/docker.io/hosts.toml"
                            content = """\
server = "https://registry-1.docker.io"

[host."harbor.dev-crossplane.test.grivit.com/v2/cache-docker-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                        {
                            path = "/etc/containerd/certs.d/quay.io/hosts.toml"
                            content = """\
server = "https://quay.io"

[host."harbor.dev-crossplane.test.grivit.com/v2/cache-quay-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                        {
                            path = "/etc/containerd/certs.d/registry.k8s.io/hosts.toml"
                            content = """\
server = "https://registry.k8s.io"

[host."harbor.dev-crossplane.test.grivit.com/v2/cache-registry-k8s-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                        {
                            path = "/etc/containerd/certs.d/ghcr.io/hosts.toml"
                            content = """\
server = "https://ghcr.io"

[host."harbor.dev-crossplane.test.grivit.com/v2/cache-ghcr-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                    ]
                    preKubeadmCommands = ["systemctl restart containerd"]
                    initConfiguration.nodeRegistration.kubeletExtraArgs = {
                        "cloud-provider" = "external"
                        "provider-id": "openstack:///'{{ instance_id }}'"
                    }
                    initConfiguration.nodeRegistration.name = "{{ local_hostname }}"
                    joinConfiguration.nodeRegistration.kubeletExtraArgs = {
                        "cloud-provider" = "external"
                        "provider-id": "openstack:///'{{ instance_id }}'"
                    }
                    joinConfiguration.nodeRegistration.name = "{{ local_hostname }}"
                }
                machineTemplate.infrastructureRef = {
                    apiVersion = "infrastructure.cluster.x-k8s.io/v1beta1"
                    kind = "OpenStackMachineTemplate"
                    name = _controlPlaneMachineTemplate.managedResource.metadata.name
                }
                machineTemplate.nodeDrainTimeout = "60s"
                replicas = _replicas
                version = _k8sVersion
            }
        }
        spec.readiness.policy = "AllTrue"
        spec.providerConfigRef.name = k8sProviderConfigName(_projectNamespace, "ctrl")
    }
    usages: [Usage] = []

    getKubernetesVersion: (any) -> str = lambda observedComposedResources: any -> str {
        _kubernetesVersion: str = _k8sVersion
        if managedResource.metadata.name in observedComposedResources:
            _kubernetesVersion = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.manifest?.status?.version or _k8sVersion)

        _kubernetesVersion
    }

    check:
        len(managedResource.metadata.name) < 64
        len(managedResource.spec.forProvider.manifest.metadata.name) < 64
