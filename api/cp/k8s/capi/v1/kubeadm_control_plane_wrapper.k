import api.cp.core.v1 as cpCore

schema KubeadmControlPlaneWrapper:
    _name: str

    _controlPlaneMachineTemplate: OsMachineTemplateWrapper
    _replicas: int
    _k8sVersion: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec.forProvider.manifest = {
            apiVersion = "controlplane.cluster.x-k8s.io/v1beta1"
            kind = "KubeadmControlPlane"
            metadata.name = _name
            metadata.namespace = _tenantNamespace
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

[host."https://harbor.hub.test.grivit.com/v2/cache-docker-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                        {
                            path = "/etc/containerd/certs.d/quay.io/hosts.toml"
                            content = """\
server = "https://quay.io"

[host."https://harbor.hub.test.grivit.com/v2/cache-quay-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                        {
                            path = "/etc/containerd/certs.d/registry.k8s.io/hosts.toml"
                            content = """\
server = "https://registry.k8s.io"

[host."https://harbor.hub.test.grivit.com/v2/cache-registry-k8s-io"]
capabilities = ["pull", "resolve"]
override_path = true
"""
                        }
                        {
                            path = "/etc/containerd/certs.d/ghcr.io/hosts.toml"
                            content = """\
server = "https://ghcr.io"

[host."https://harbor.hub.test.grivit.com/v2/cache-ghcr-io"]
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
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [cpCore.Usage] = []

