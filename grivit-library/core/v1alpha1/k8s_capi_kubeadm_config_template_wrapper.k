schema K8sCapiKubeadmConfigTemplateWrapper:
    _name: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec = {
            forProvider = {
                manifest = {
                    apiVersion = "bootstrap.cluster.x-k8s.io/v1beta1"
                    kind = "KubeadmConfigTemplate"
                    metadata.name = _name
                    metadata.namespace = _tenantNamespace
                    spec.template.spec = {
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
                        joinConfiguration.nodeRegistration = {
                            kubeletExtraArgs = {
                                "cloud-provider" = "external"
                                "provider-id": "openstack:///'{{ instance_id }}'"
                            }
                            name = "{{ local_hostname }}"
                        }
                    }
                }
            }
        }
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = []

