import api.cp.core.v1 as cpCore

schema OsClusterWrapper:
    _name: str

    _cloudConfigName: str
    _externalNetworkName: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec.forProvider.manifest = {
            apiVersion = "infrastructure.cluster.x-k8s.io/v1beta1"
            kind = "OpenStackCluster"
            metadata.name = _name
            metadata.namespace = _tenantNamespace
            spec = {
                apiServerLoadBalancer.provider = "ovn"
                externalNetwork.filter.name = _externalNetworkName
                identityRef.cloudName = "openstack"
                identityRef.name = _cloudConfigName
                managedSecurityGroups.allNodesSecurityGroupRules = [
                    {
                        description = "Created by cluster-api-provider-openstack - VXLAN overlay (Cilium)"
                        direction = "ingress"
                        etherType = "IPv4"
                        name = "VXLAN overlay (Cilium)"
                        portRangeMax = 8472
                        portRangeMin = 8472
                        protocol = "UDP"
                        remoteManagedGroups = ["controlplane", "worker"]
                    }
                    {
                        description = "Created by cluster-api-provider-openstack - health checks (Cilium)"
                        direction = "ingress"
                        etherType = "IPv4"
                        name = "Health checks (Cilium)"
                        portRangeMax = 4240
                        portRangeMin = 4240
                        protocol = "UDP"
                        remoteManagedGroups = ["controlplane", "worker"]
                    }
                    {
                        description = "Created by cluster-api-provider-openstack - ICMP health checks (Cilium)"
                        direction = "ingress"
                        etherType = "IPv4"
                        name = "ICMP health checks (Cilium)"
                        protocol = "ICMP"
                        remoteManagedGroups = ["controlplane", "worker"]
                    }
                    {
                        description = "Node Port Services"
                        direction = "ingress"
                        etherType = "IPv4"
                        name = "Node Port Services"
                        portRangeMax = 32767
                        portRangeMin = 30000
                        protocol = "TCP"
                    }
                ]
                managedSubnets = [{
                    cidr = "10.4.1.0/24"
                    dnsNameservers = ["10.21.0.1"]
                }]
            }
        }
        spec.readiness.celQuery = "object.status.ready == true"
        spec.readiness.policy = "DeriveFromCelQuery"
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [cpCore.Usage] = []

