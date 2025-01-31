import core.v1alpha1 as core

k8sClusterOsK0smotronNameSingular: str = "OsK0smotronCluster"
k8sClusterOsK0smotronNamePlural: str = "OsK0smotronClusters"
k8sClusterOsK0smotronApiGroup: str = "k8s.grivit.cloud"
k8sClusterOsK0smotronApiVersion: str = "v1alpha1"

k8sClusterOsK0smotronXr: core.k8sClusterOsK0smotronXr = core.k8sClusterOsK0smotronXr {
    _nameSingular = k8sClusterOsK0smotronNameSingular
    _apiGroup = k8sClusterOsK0smotronApiGroup
    _apiVersion = k8sClusterOsK0smotronApiVersion
}

k8sClusterOsK0smotronXrd: core.k8sClusterOsK0smotronXrd = core.k8sClusterOsK0smotronXrd {
    _nameSingular = k8sClusterOsK0smotronNameSingular
    _namePlural = k8sClusterOsK0smotronNamePlural
    _apiGroup = k8sClusterOsK0smotronApiGroup
    _apiVersion = k8sClusterOsK0smotronApiVersion
}
