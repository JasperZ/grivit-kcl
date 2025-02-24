import core.v1alpha1 as core

schema KcClientArgoCd:
    _clientId: str
    _clusterName: str
    _domain: str
    _name: str
    _observedComposedResources: any
    _realmId: str
    _projectNamespace: str
    _instanceName: str

    kcClient: core.KcOpenIdClientWrapper {
        _clientId = _clientId
        _description = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX."
        _instanceName = _instanceName
        _name = "${_name}-client"
        _projectNamespace = _projectNamespace
        _realmId = _realmId
        _validRedirectUris = [
            "http://localhost:8085/auth/callback"
            "https://${_domain}/auth/callback"
        ]
        _url = "https://${_domain}"
    }
    kcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = kcClient.getAtProviderId(_observedComposedResources)
        _instanceName = _instanceName
        _name = "${_name}-client-default-scopes"
        _projectNamespace = _projectNamespace
        _realmId = _realmId
    }
    k8sClientCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = "${_name}-client-credentials"
        _namespace = "crossplane-secrets"
        _projectNamespace = _projectNamespace
        _secretName = _clientId
        _stringData = {
            clientId = _clientId
            clientSecret = kcClient.getClientSecret(_observedComposedResources)
        }
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

