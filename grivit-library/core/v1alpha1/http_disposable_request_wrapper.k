schema HttpDisposableRequestWrapper:
    _name: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "http.crossplane.io/v1alpha2"
        kind = "DisposableRequest"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider = {}
        spec.providerConfigRef.name = "${_projectNamespace}-http"
    }
    usages: [Usage] = []

    getResponseBody: (any) -> str = lambda observedComposedResources: any -> str {
        _body: str = ""

        if managedResource.metadata.name in observedComposedResources:
            _body = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.response?.body or "")

        _body
    }