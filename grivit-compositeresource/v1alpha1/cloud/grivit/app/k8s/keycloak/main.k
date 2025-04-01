import manifests

nameSingularKeycloakAppK8s: str = "Keycloak"
namePluralKeycloakAppK8s: str = "Keycloaks"
apiGroupKeycloakAppK8s: str = "k8s.app.grivit.cloud"
apiVersionKeycloakAppK8s: str = "v1alpha1"

xrKeycloakAppK8s: XrKeycloakAppK8s = XrKeycloakAppK8s {
    _nameSingular = nameSingularKeycloakAppK8s
    _apiGroup = apiGroupKeycloakAppK8s
    _apiVersion = apiVersionKeycloakAppK8s
}

xrdKeycloakAppK8s: XrdKeycloakAppK8s = XrdKeycloakAppK8s {
    _nameSingular = nameSingularKeycloakAppK8s
    _namePlural = namePluralKeycloakAppK8s
    _apiGroup = apiGroupKeycloakAppK8s
    _apiVersion = apiVersionKeycloakAppK8s
}

manifests.yaml_stream([
    xrKeycloakAppK8s
    xrdKeycloakAppK8s
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
