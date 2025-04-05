schema KcGroupArgoCdWrapper:
    _argoCdInstance: ArgoCdInstance
    _groupType: "admins" | "viewers"
    _keycloakInstance: KeycloakInstance
    _projectName: str
    _uses: [ManagedResource] = []

    _groupName: str = "argocd-${_argoCdInstance.ownerProjectName}-${_argoCdInstance.name}-${_argoCdInstance.projectName}-${_groupType}"
    _resourceName: str = "${_projectName}-${_groupName}"

    managedResource: ManagedResource {
        apiVersion = "group.keycloak.crossplane.io/v1alpha1"
        kind = "Group"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        metadata.labels = {
            "argocd-instance" = _argoCdInstance.name
            "argocd-instance-owner-project" = _argoCdInstance.ownerProjectName
            "argocd-project-name" = _argoCdInstance.projectName
            "keycloak-instance" = _keycloakInstance.name
            "keycloak-instance-owner-project" = _keycloakInstance.ownerProjectName
            "keycloak-realm-id" = _keycloakInstance.realmId
            "project" = _projectName
        }
        spec.forProvider.name = _groupName
        spec.forProvider.realmId = _keycloakInstance.realmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstance)
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

    getAtProviderId: (any) -> str = lambda observedComposedResources: any -> str {
        _atProviderId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _atProviderId = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.id or "")

        _atProviderId
    }

