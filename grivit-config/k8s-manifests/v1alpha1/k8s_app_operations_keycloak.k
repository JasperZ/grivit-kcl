import core.v1alpha1 as core

k8sAppOperationsKeycloakNameSingular: str = "AppOperationsKeycloak"
k8sAppOperationsKeycloakNamePlural: str = "AppOperationsKeycloaks"
k8sAppOperationsKeycloakApiGroup: str = "k8s.grivit.cloud"
k8sAppOperationsKeycloakApiVersion: str = "v1alpha1"

k8sAppOperationsKeycloakXr: core.k8sAppOperationsKeycloakXr = core.k8sAppOperationsKeycloakXr {
    _nameSingular = k8sClusterOsStandaloneNameSingular
    _apiGroup = k8sClusterOsStandaloneApiGroup
    _apiVersion = k8sClusterOsStandaloneApiVersion
}

k8sAppOperationsKeycloakXrd: core.k8sAppOperationsKeycloakXrd = core.k8sAppOperationsKeycloakXrd {
    _nameSingular = k8sClusterOsStandaloneNameSingular
    _namePlural = k8sClusterOsStandaloneNamePlural
    _apiGroup = k8sClusterOsStandaloneApiGroup
    _apiVersion = k8sClusterOsStandaloneApiVersion
}
