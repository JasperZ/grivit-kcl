schema K8sFluxGitRepositoryWrapper:
    _gitTag: str
    _gitUrl: str
    _name: str
    _projectNamespace: str

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
                    kind = "GitRepository"
                    metadata = {
                        name = _name
                        namespace = _projectNamespace
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
            providerConfigRef.name = k8sProviderConfigName(_projectNamespace, "ctrl")
        }
    }
    usages: [Usage] = []

    check:
        len(managedResource.metadata.name) < 64    
