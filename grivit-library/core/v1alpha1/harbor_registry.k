schema HarborRegistry:
    _harborRegistryDescription: str
    _harborRegistryEndpointUrl: str
    _harborRegistryInsecure: bool = False
    _harborRegistryName: str
    _harborRegistryProviderName: "alibaba" | "artifact-hub" | "aws" | "azure" | "docker-hub" | "docker-registry" | "gitlab" | "github" | "google" | "harbor" | "huawei" | "jfrog" | "quay"
    _resourceName: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "registry.harbor.crossplane.io/v1alpha1"
        kind = "Registry"
        metadata.name = _resourceName
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
        spec.providerConfigRef.name = "bootstrap-harbor"
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

    getProviderAtRegistryId: (any) -> int = lambda observedComposedResources: any -> int {
        _registryId: int = 1234567890
        if managedResource.metadata.name in observedComposedResources:
            if observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.registryId:
                _registryId = int(observedComposedResources[managedResource.metadata.name].Resource.status.atProvider.registryId)

        _registryId
    }

