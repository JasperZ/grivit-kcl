schema KcGroupArgoCdWrapper:
    _argoCdInstanceName: str
    _argoCdInstanceOwnerProjectName: str
    _argoCdProjectName: str
    _groupType: "admins" | "viewers"
    _keycloakInstanceName: str
    _keycloakInstanceOwnerProjectName: str
    _keycloakRealmId: str
    _projectName: str
    _uses: [ManagedResource] = []

    _groupName: str = "argocd-${_argoCdInstanceOwnerProjectName}-${_argoCdInstanceName}-${_argoCdProjectName}-${_groupType}"
    _resourceName: str = "${_projectName}-${_groupName}"

    managedResource: ManagedResource {
        apiVersion = "group.keycloak.crossplane.io/v1alpha1"
        kind = "Group"
        metadata.name = _resourceName
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _resourceName
        }
        metadata.labels = {
            "argocd-instance" = _argoCdInstanceName
            "argocd-instance-owner-project" = _argoCdInstanceOwnerProjectName
            "argocd-project-name" = _argoCdProjectName
            "keycloak-instance" = _keycloakInstanceName
            "keycloak-instance-owner-project" = _keycloakInstanceOwnerProjectName
            "keycloak-realm-id" = _keycloakRealmId
            "project" = _projectName
        }
        spec.forProvider.name = _groupName
        spec.forProvider.realmId = _keycloakRealmId
        spec.providerConfigRef.name = kcProviderConfigName(_projectName, _keycloakInstanceOwnerProjectName, _keycloakInstanceName, _keycloakRealmId)
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

