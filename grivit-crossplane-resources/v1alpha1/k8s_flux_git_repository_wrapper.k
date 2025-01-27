schema K8sFluxGitRepositoryWrapper:
    _name: str
    _gitUrl: str
    _gitTag: str
    _controlPlaneK8sProviderConfigName: str
    _tenantNamespace: str

    managedResource: ManagedResource {
        apiVersion = "kubernetes.crossplane.io/v1alpha2"
        kind = "Object"
        metadata.name = _name
        spec = {
            forProvider = {
                manifest = {
                    apiVersion = "source.toolkit.fluxcd.io/v1"
                    kind = "GitRepository"
                    metadata = {
                        name = _name
                        namespace = _tenantNamespace
                    }
                    spec = {
                        interval = "1h"
                        url = _gitUrl
                        ref = {
                            tag = _gitTag
                        }
                    }
                }
            }
            providerConfigRef.name = _controlPlaneK8sProviderConfigName
        }
    }
    usages: [Usage] = []

