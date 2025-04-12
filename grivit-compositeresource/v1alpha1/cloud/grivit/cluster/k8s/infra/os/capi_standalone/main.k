import manifests

nameSingularCapiStandaloneClusterK8sInfraOs: str = "CapiStandalone"
namePluralCapiStandaloneClusterK8sInfraOs: str = "CapiStandalones"
apiGroupCapiStandaloneClusterK8sInfraOs: str = "os.infra.k8s.cluster.grivit.cloud"
apiVersionCapiStandaloneClusterK8sInfraOs: str = "v1alpha1"

xrCapiStandaloneClusterK8sInfraOs: XrCapiStandaloneClusterK8sInfraOs = XrCapiStandaloneClusterK8sInfraOs {
    _nameSingular = nameSingularCapiStandaloneClusterK8sInfraOs
    _apiGroup = apiGroupCapiStandaloneClusterK8sInfraOs
    _apiVersion = apiVersionCapiStandaloneClusterK8sInfraOs
}

xrdCapiStandaloneClusterK8sInfraOs: XrdCapiStandaloneClusterK8sInfraOs = XrdCapiStandaloneClusterK8sInfraOs {
    _nameSingular = nameSingularCapiStandaloneClusterK8sInfraOs
    _namePlural = namePluralCapiStandaloneClusterK8sInfraOs
    _apiGroup = apiGroupCapiStandaloneClusterK8sInfraOs
    _apiVersion = apiVersionCapiStandaloneClusterK8sInfraOs
}

manifests.yaml_stream([
    xrCapiStandaloneClusterK8sInfraOs
    xrdCapiStandaloneClusterK8sInfraOs
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
