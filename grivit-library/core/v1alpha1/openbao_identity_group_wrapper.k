schema OpenBaoIdentityGroupWrapper:
    _groupExternalMemberEntityIds: bool = False
    _groupExternalMemberGroupIds: bool = False
    _groupExternalPolicies: bool = False
    _groupMemberEntityIds: [str] = []
    _groupMemberGroupIds: [str] = []
    _groupMetadata: {str:str} = {}
    _groupName: str
    _groupPolicies: [str] = []
    _groupType: "external" | "internal"
    _instanceName: str
    _instanceOwnerProjectName: str
    _name: str
    _projectName: str

    managedResource: ManagedResource {
        apiVersion = "identity.vault.upbound.io/v1alpha1"
        kind = "Group"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider = {
            externalMemberEntityIds = _groupExternalMemberEntityIds
            externalMemberGroupIds = _groupExternalMemberGroupIds
            externalPolicies = _groupExternalPolicies
            memberEntityIds = _groupMemberEntityIds
            memberGroupIds = _groupMemberGroupIds
            metadata = _groupMetadata
            name = _groupName
            policies = _groupPolicies
            type = _groupType
        }
        spec.providerConfigRef.name = openBaoProviderConfigName(_projectName, _instanceName, _instanceOwnerProjectName, _projectName)
    }
    usages: [Usage] = []

