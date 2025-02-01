schema K8sCapiK0smotronWorkerConfigTemplateWrapper:
    _name: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str
    # _k8sVersion: str

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
                    kind = "K0sWorkerConfigTemplate"
                    metadata.name = _name
                    metadata.namespace = _tenantNamespace
                    spec.template.spec = {
                        # version = "${_k8sVersion}+k0s.0"
                        args = [
                            "--enable-cloud-provider"
                            '--kubelet-extra-args="--cloud-provider=external --provider-id=openstack:///{{ instance_id }}"'
                        ]
                    }
                }
            }
        }
        spec.providerConfigRef.name = _controlPlaneK8sProviderConfigName
    }
    usages: [Usage] = []

