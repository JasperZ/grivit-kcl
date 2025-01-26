import api.cp.core.v1 as cpCore

schema OsIdentityRoleAssignmentWrapper:
    _controlPlaneOsProviderConfigName: str
    _name: str
    _projectId: str
    _roleId: str = "2c7221f94f95476bab7416d406d8df1b"
    _userId: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "RoleAssignmentV3"
        metadata.name = _name
        spec.forProvider.projectId = _projectId
        # ToDo: make configurable
        spec.forProvider.roleId = _roleId
        spec.forProvider.userId = _userId
        spec.providerConfigRef.name = _controlPlaneOsProviderConfigName
    }
    usages: [cpCore.Usage] = []

