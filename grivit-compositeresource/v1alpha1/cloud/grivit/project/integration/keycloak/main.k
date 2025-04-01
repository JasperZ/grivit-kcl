import manifests

nameSingularKeycloakProjectIntegration: str = "Keycloak"
namePluralKeycloakProjectIntegration: str = "Keycloaks"
apiGroupKeycloakProjectIntegration: str = "integration.project.grivit.cloud"
apiVersionKeycloakProjectIntegration: str = "v1alpha1"

xrKeycloakProjectIntegration: XrKeycloakProjectIntegration = XrKeycloakProjectIntegration {
    _nameSingular = nameSingularKeycloakProjectIntegration
    _apiGroup = apiGroupKeycloakProjectIntegration
    _apiVersion = apiVersionKeycloakProjectIntegration
}

xrdKeycloakProjectIntegration: XrdKeycloakProjectIntegration = XrdKeycloakProjectIntegration {
    _nameSingular = nameSingularKeycloakProjectIntegration
    _namePlural = namePluralKeycloakProjectIntegration
    _apiGroup = apiGroupKeycloakProjectIntegration
    _apiVersion = apiVersionKeycloakProjectIntegration
}

manifests.yaml_stream([
    xrKeycloakProjectIntegration
    xrdKeycloakProjectIntegration
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
