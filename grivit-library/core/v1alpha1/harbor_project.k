schema HarborProject:
    _harborProjectEnableContentTrust: bool = False
    _harborProjectEnableContentTrustCosign: bool = False
    _harborProjectName: str
    _harborProjectRegistryId: str
    _harborProjectVulnerabilityScanning: bool = True
    _resourceName: str
    _resourceNamespace: str
    _uses: [ManagedResource] = []

    managedResource: ManagedResource {
        apiVersion = "project.harbor.crossplane.io/v1alpha1"
        kind = "Project"
        metadata.name = _resourceName
        metadata.namespace = _resourceNamespace
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            enableContentTrust: _harborProjectEnableContentTrust
            enableContentTrustCosign: _harborProjectEnableContentTrustCosign
            name: _harborProjectName
            registryId: _harborProjectRegistryId
            vulnerabilityScanning: _harborProjectVulnerabilityScanning
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

