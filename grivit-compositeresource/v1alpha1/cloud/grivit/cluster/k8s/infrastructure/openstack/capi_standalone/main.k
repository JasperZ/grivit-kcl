import manifests

nameSingularCapiStandaloneClusterK8sInfrastructureOpenStack: str = "CapiStandalone"
namePluralCapiStandaloneClusterK8sInfrastructureOpenStack: str = "CapiStandalones"
apiGroupCapiStandaloneClusterK8sInfrastructureOpenStack: str = "openstack.infrastructure.k8s.cluster.grivit.cloud"
apiVersionCapiStandaloneClusterK8sInfrastructureOpenStack: str = "v1alpha1"

xrCapiStandaloneClusterK8sInfrastructureOpenStack: XrCapiStandaloneClusterK8sInfrastructureOpenStack = XrCapiStandaloneClusterK8sInfrastructureOpenStack {
    _nameSingular = nameSingularCapiStandaloneClusterK8sInfrastructureOpenStack
    _apiGroup = apiGroupCapiStandaloneClusterK8sInfrastructureOpenStack
    _apiVersion = apiVersionCapiStandaloneClusterK8sInfrastructureOpenStack
}

xrdCapiStandaloneClusterK8sInfrastructureOpenStack: XrdCapiStandaloneClusterK8sInfrastructureOpenStack = XrdCapiStandaloneClusterK8sInfrastructureOpenStack {
    _nameSingular = nameSingularCapiStandaloneClusterK8sInfrastructureOpenStack
    _namePlural = namePluralCapiStandaloneClusterK8sInfrastructureOpenStack
    _apiGroup = apiGroupCapiStandaloneClusterK8sInfrastructureOpenStack
    _apiVersion = apiVersionCapiStandaloneClusterK8sInfrastructureOpenStack
}

manifests.yaml_stream([
    xrCapiStandaloneClusterK8sInfrastructureOpenStack
    xrdCapiStandaloneClusterK8sInfrastructureOpenStack
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
