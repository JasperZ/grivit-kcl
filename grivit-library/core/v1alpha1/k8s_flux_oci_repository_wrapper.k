schema K8sFluxOciRepositoryWrapper:
    _name: str
    _projectNamespace: str
    _tag: str
    _url: str

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
                    apiVersion = "source.toolkit.fluxcd.io/v1beta2"
                    kind = "OCIRepository"
                    metadata = {
                        name = _name
                        namespace = _projectNamespace
                    }
                    spec = {
                        interval = "1h"
                        url = _url
                        ref = {
                            tag = _tag
                        }
                    }
                }
            }
            providerConfigRef.name = "${_projectNamespace}-k8s-ctrl"
        }
    }
    usages: [Usage] = []

