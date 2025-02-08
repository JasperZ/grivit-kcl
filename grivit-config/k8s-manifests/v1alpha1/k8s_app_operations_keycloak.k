import core.v1alpha1 as core

k8sAppOperationsKeycloakNameSingular: str = "AppOperationsKeycloak"
k8sAppOperationsKeycloakNamePlural: str = "AppOperationsKeycloaks"
k8sAppOperationsKeycloakApiGroup: str = "k8s.grivit.cloud"
k8sAppOperationsKeycloakApiVersion: str = "v1alpha1"

k8sAppOperationsKeycloakXr: core.k8sAppOperationsKeycloakXr = core.k8sAppOperationsKeycloakXr {
    _nameSingular = k8sAppOperationsKeycloakNameSingular
    _apiGroup = k8sAppOperationsKeycloakApiGroup
    _apiVersion = k8sAppOperationsKeycloakApiVersion
}

k8sAppOperationsKeycloakXrd: core.k8sAppOperationsKeycloakXrd = core.k8sAppOperationsKeycloakXrd {
    _nameSingular = k8sAppOperationsKeycloakNameSingular
    _namePlural = k8sAppOperationsKeycloakNamePlural
    _apiGroup = k8sAppOperationsKeycloakApiGroup
    _apiVersion = k8sAppOperationsKeycloakApiVersion
}
