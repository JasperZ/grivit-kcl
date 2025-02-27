schema KcProviderConfigWrapper:
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _kcInstanceName: str
    _kcInstanceOwnerProjectName: str
    _kcRealmId: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _resourceName: str = "${_projectNamespace}-kc-${_kcInstanceOwnerProjectName}-${_kcInstanceName}-${_kcRealmId}"

    managedResource: KcProviderConfig {
        _name = _resourceName
        _credentialsSecretName = _credentialsSecretName
        _credentialsSecretNamespace = _credentialsSecretNamespace
        metadata.labels = {
            "keycloak-instance" = _kcInstanceName
            "keycloak-instance-owner-roject" = _kcInstanceOwnerProjectName
            "keycloak-realm-id" = _kcRealmId
            "project" = _projectNamespace
        }
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

