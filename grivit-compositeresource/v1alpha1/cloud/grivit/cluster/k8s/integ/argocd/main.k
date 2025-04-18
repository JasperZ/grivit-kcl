import manifests

nameSingularArgoCdIntegK8sCluster: str = "ArgoCd"
namePluralArgoCdIntegK8sCluster: str = "ArgoCds"
apiGroupArgoCdIntegK8sCluster: str = "integ.k8s.cluster.grivit.cloud"
apiVersionArgoCdIntegK8sCluster: str = "v1alpha1"

xrArgoCdIntegK8sCluster: XrArgoCdIntegK8sCluster = XrArgoCdIntegK8sCluster {
    _nameSingular = nameSingularArgoCdIntegK8sCluster
    _apiGroup = apiGroupArgoCdIntegK8sCluster
    _apiVersion = apiVersionArgoCdIntegK8sCluster
}

xrdArgoCdIntegK8sCluster: XrdArgoCdIntegK8sCluster = XrdArgoCdIntegK8sCluster {
    _nameSingular = nameSingularArgoCdIntegK8sCluster
    _namePlural = namePluralArgoCdIntegK8sCluster
    _apiGroup = apiGroupArgoCdIntegK8sCluster
    _apiVersion = apiVersionArgoCdIntegK8sCluster
}

manifests.yaml_stream([
    xrArgoCdIntegK8sCluster
    xrdArgoCdIntegK8sCluster
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
