schema HarborRegistry:
    _harborRegistryDescription: str
    _harborRegistryEndpointUrl: str
    _harborRegistryInsecure: bool = False
    _harborRegistryName: str
    _harborRegistryProviderName: "alibaba" | "artifact-hub" | "aws" | "azure" | "docker-hub" | "docker-registry" | "gitlab" | "github" | "google" | "harbor" | "huawei" | "jfrog" | "quay"
    _resourceName: str
    _resourceNamespace: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "registry.harbor.crossplane.io/v1alpha1"
        kind = "Registry"
        metadata.name = _resourceName
        metadata.namespace = _resourceNamespace
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            description: _harborRegistryDescription
            endpointUrl: _harborRegistryEndpointUrl
            insecure: _harborRegistryInsecure
            name: _harborRegistryName
            providerName: _harborRegistryProviderName
        }
        spec.providerConfigRef.name = "bootstrap-harbor-provider"
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_resourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_resourceName}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

    getProviderAtRegistryId: (any) -> str = lambda observedComposedResources: any -> str {
        _registryId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _registryId = str(base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails?.username))

        _registryId
    }

