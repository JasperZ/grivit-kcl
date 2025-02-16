import core.v1alpha1 as core

schema KcClientArgoCd:
    _clientId: str
    _domain: str
    _name: str
    _observedComposedResources: any
    _realmId: str
    _targetK8sProviderConfigWrapper: core.K8sProviderConfigWrapper
    _targetKcProviderConfigWrapper: core.KcProviderConfigWrapper
    _tenantNamespace: str

    kcClient: core.KcOpenIdClientWrapper {
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _clientId = _clientId
        _name = "${_name}-client"
        _realmId = _realmId
        _redirectUri = "https://${_domain}/auth/callback"
        _tenantNamespace = _tenantNamespace
        _url = "https://${_domain}"
    }
    kcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _targetKcProviderConfigWrapper = _targetKcProviderConfigWrapper
        _clientId = kcClient.getId(_observedComposedResources)
        _name = "${_name}-client-default-scopes"
        _realmId = _realmId
    }
    k8sClientCredentialsSecret: core.K8sObjectSecretWrapper {
        _name = "${_realmId}-${_clientId}"
        _stringData = {
            clientId = _clientId
            clientSecret = kcClient.getClientSecret(_observedComposedResources)
        }
        _targetK8sProviderConfigName = _targetK8sProviderConfigWrapper.managedResource.metadata.name
        # ToDo: think about a better place
        _targetNamespace = "default"
    }
    managedResources: [core.ManagedResource | core.KcProviderConfig] = [
        kcClient.managedResource
        kcClientDefaultScopes.managedResource
        k8sClientCredentialsSecret.managedResource
    ]

    usages: [core.Usage] = sum([
        kcClient.usages
        kcClientDefaultScopes.usages
        k8sClientCredentialsSecret.usages
    ], [])

