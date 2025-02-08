import core.v1alpha1 as core

k8sAppOperationsArgoCdNameSingular: str = "AppOperationsArgoCd"
k8sAppOperationsArgoCdNamePlural: str = "AppOperationsArgoCds"
k8sAppOperationsArgoCdApiGroup: str = "k8s.grivit.cloud"
k8sAppOperationsArgoCdApiVersion: str = "v1alpha1"

k8sAppOperationsArgoCdXr: core.k8sAppOperationsArgoCdXr = core.k8sAppOperationsArgoCdXr {
    _nameSingular = k8sAppOperationsArgoCdNameSingular
    _apiGroup = k8sAppOperationsArgoCdApiGroup
    _apiVersion = k8sAppOperationsArgoCdApiVersion
}

k8sAppOperationsArgoCdXrd: core.k8sAppOperationsArgoCdXrd = core.k8sAppOperationsArgoCdXrd {
    _nameSingular = k8sAppOperationsArgoCdNameSingular
    _namePlural = k8sAppOperationsArgoCdNamePlural
    _apiGroup = k8sAppOperationsArgoCdApiGroup
    _apiVersion = k8sAppOperationsArgoCdApiVersion
}
