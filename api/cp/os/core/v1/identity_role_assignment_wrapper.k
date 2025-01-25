import api.cp.core.v1 as cpCore

schema IdentityRoleAssignmentWrapper:
    _controlPlaneOsProviderConfigName: str
    _name: str
    _osProject: IdentityProjectWrapper
    _osUser: IdentityUserWrapper

    _projectId = None
    _projectName = _osProject.managedResource.metadata.name
    if _projectName in ocds:
        _projectId = ocds[_projectName].Resource?.status?.atProvider?.id or ""

    _userId = None
    _userName = _osUser.managedResource.metadata.name
    if _userName in ocds:
        _userId = ocds[_userName].Resource?.status?.atProvider?.id or ""

    managedResource: cpCore.ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "RoleAssignmentV3"
        metadata.name = _name
        spec.forProvider.projectId = _projectId
        # ToDo: make configurable
        spec.forProvider.roleId = "2c7221f94f95476bab7416d406d8df1b"
        spec.forProvider.userId = _userId
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [cpCore.Usage] = []

