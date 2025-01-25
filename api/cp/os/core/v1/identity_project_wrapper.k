import api.cp.core.v1 as cpCore

schema IdentityProjectWrapper:
    _controlPlaneOsProviderConfigName: str
    _projectName: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ProjectV3"
        metadata.name = _projectName
        spec.forProvider.description = "Project '${_projectName}' manged by Crossplane"
        spec.forProvider.name = _projectName
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [cpCore.Usage] = []

