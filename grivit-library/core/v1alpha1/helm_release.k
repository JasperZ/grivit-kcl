schema HelmReleaseWrapper:
    _chartName: str
    _chartRepoUrl: str
    _chartVersion: str
    _clusterName: str
    _name: str
    _projectNamespace: str
    _targetNamespace: str

    managedResource: ManagedResource {
        apiVersion = "helm.crossplane.io/v1beta1"
        kind = "Release"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider = {
            chart = {
                name = _chartName
                repository = _chartRepoUrl
                version = _chartVersion
            }
            namespace = _targetNamespace
            skipCreateNamespace = False
        }
        spec.providerConfigRef.name = helmProviderConfigName(_projectNamespace, _clusterName)
    }
    usages: [Usage] = []

