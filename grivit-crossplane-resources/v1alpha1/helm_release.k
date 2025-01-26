import api.cp.core.v1 as cpCore

schema HelmReleaseWrapper:
    _name: str
    _chartName: str
    _chartVersion: str
    _chartRepoUrl: str
    _releaseNamespace: str

    _targetHelmProviderConfigName: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "helm.crossplane.io/v1beta1"
        kind = "Release"
        metadata.name = _name
        spec.forProvider = {
            chart = {
                name = _chartName
                repository = _chartRepoUrl
                version = _chartVersion
            }
            namespace = _releaseNamespace
            skipCreateNamespace = False
        }
        spec.providerConfigRef.name = _targetHelmProviderConfigName
    }
    usages: [cpCore.Usage] = []

