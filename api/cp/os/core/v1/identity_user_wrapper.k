import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore

schema IdentityUserWrapper:
    _controlPlaneOsProviderConfigName: str
    _name: str
    _osProject: IdentityProjectWrapper
    _passwordSecret: cpK8sCore.ObjectSecretWrapper
    _passwordSecretKey: str
    _userName: str
    _uses: [cpCore.ManagedResource] = []

    _projectId = None
    _projectName = _osProject.managedResource.metadata.name
    if _projectName in ocds:
        _projectId = ocds[_projectName].Resource?.status?.atProvider?.id or ""

    managedResource: cpCore.ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "UserV3"
        metadata.name = _name
        spec.forProvider.defaultProjectId = _projectId
        spec.forProvider.description = "User '${_userName}' managed and used by Crossplane to access the project '${_projectName}'"
        spec.forProvider.name = _userName
        spec.forProvider.passwordSecretRef = {
            key = _passwordSecretKey
            name = _passwordSecret.managedResource.spec.forProvider.manifest.metadata.name
            namespace = _passwordSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        }
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [cpCore.Usage] = [cpCore.Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

