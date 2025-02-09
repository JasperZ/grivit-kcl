import core.v1alpha1 as core

k8sClusterOsStandaloneNameSingular: str = "OsStandaloneCluster"
k8sClusterOsStandaloneNamePlural: str = "OsStandaloneClusters"
k8sClusterOsStandaloneApiGroup: str = "k8s.grivit.cloud"
k8sClusterOsStandaloneApiVersion: str = "v1alpha1"

k8sClusterOsStandaloneXr: core.K8sClusterOsStandaloneXr = core.K8sClusterOsStandaloneXr {
    _nameSingular = k8sClusterOsStandaloneNameSingular
    _apiGroup = k8sClusterOsStandaloneApiGroup
    _apiVersion = k8sClusterOsStandaloneApiVersion
}

k8sClusterOsStandaloneXrd: core.K8sClusterOsStandaloneXrd = core.K8sClusterOsStandaloneXrd {
    _nameSingular = k8sClusterOsStandaloneNameSingular
    _namePlural = k8sClusterOsStandaloneNamePlural
    _apiGroup = k8sClusterOsStandaloneApiGroup
    _apiVersion = k8sClusterOsStandaloneApiVersion
}
