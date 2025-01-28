schema K8sFluxHelmRepositoryWrapper:
    _name: str
    _helmRepoUrl: str
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
                    apiVersion = "source.toolkit.fluxcd.io/v1"
                    kind = "HelmRepository"
                    metadata = {
                        name = _name
                        namespace = _tenantNamespace
                    }
                    spec = {
                        interval = "1h"
                        url = _helmRepoUrl
                    }
                }
            }
            providerConfigRef.name = _controlPlaneK8sProviderConfigName
        }
    }
    usages: [Usage] = []

