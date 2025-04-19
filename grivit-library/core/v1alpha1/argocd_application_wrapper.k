schema ArgoCdApplicationWrapper:
    _argoCdApplicationDestinationName: str
    _argoCdApplicationSource: {any:any} = {}
    _argoCdApplicationSources: [any] = []
    _argoCdApplicationSyncWave: str = "0"
    _argoCdInstance: ArgoCdInstance
    _projectName: str
    _resourceName: str
    _uses: [ManagedResource | K8sProviderConfig] = []

    managedResource: ManagedResource {
        # https://marketplace.upbound.io/providers/crossplane-contrib/provider-argocd/v0.10.1/resources/applications.argocd.crossplane.io/Application/v1alpha1
        apiVersion = "applications.argocd.crossplane.io/v1alpha1"
        kind = "Application"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        spec.forProvider = {
            annotations = {
                "argocd.argoproj.io/sync-wave" = _argoCdApplicationSyncWave
            }
            destination = {
                name = _argoCdApplicationDestinationName
            }
            finalizers = ["resources-finalizer.argocd.argoproj.io"]
            project = argoCdTenantProjectName(_argoCdInstance)
            source = _argoCdApplicationSource
            sources = _argoCdApplicationSources
        }
        spec.providerConfigRef.name = argoCdProviderConfigName(_projectName, _argoCdInstance)
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

