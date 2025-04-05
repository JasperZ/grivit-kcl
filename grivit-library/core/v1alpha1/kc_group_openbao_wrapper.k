# schema KcGroupOpenBaoWrapper:
#     _groupType: "admins" | "viewers"
#     _keycloakInstance: KeycloakInstance
#     _openBaoInstanceName: str
#     _openBaoProjectName: str
#     _projectNamespace: str
#     _uses: [ManagedResource] = []

#     _groupName: str = "openbao-${_openBaoInstanceName}-${_openBaoProjectName}-${_groupType}"
#     _resourceName: str = "${_projectNamespace}-${_keycloakInstance.ownerProjectName}-${_keycloakInstance.name}-${_keycloakInstance.realmId}-openbao-${_openBaoProjectName}-${_groupType}-group"

#     managedResource: ManagedResource {
#         apiVersion = "group.keycloak.crossplane.io/v1alpha1"
#         kind = "Group"
#         metadata.name = _resourceName
#         metadata.annotations = {
#             "krm.kcl.dev/composition-resource-name" = _resourceName
#         }
#         spec.forProvider.name = _groupName
#         spec.forProvider.realmId = _keycloakInstance.realmId
#         spec.providerConfigRef.name = kcProviderConfigName(_projectNamespace, _keycloakInstance)
#     }
#     usages: [Usage] = [Usage {
#         metadata.name = "${_resourceName}-uses-${ofResource.metadata.name}"
#         metadata.annotations = {
#             "krm.kcl.dev/composition-resource-name" = "${_resourceName}-uses-${ofResource.metadata.name}"
#         }
#         spec.by.apiVersion = managedResource.apiVersion
#         spec.by.kind = managedResource.kind
#         spec.by.resourceRef.name = managedResource.metadata.name
#         spec.of.apiVersion = ofResource.apiVersion
#         spec.of.kind = ofResource.kind
#         spec.of.resourceRef.name = ofResource.metadata.name
#     } for ofResource in _uses]

#     getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
#         _atProviderId: str = ""
#         if managedResource.metadata.name in observedComposedResources:
#             _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

#         _atProviderId
#     }

