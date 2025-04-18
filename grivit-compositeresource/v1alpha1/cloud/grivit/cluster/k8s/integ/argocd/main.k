import manifests

nameSingularArgoCdIntK8sCluster: str = "ArgoCd"
namePluralArgoCdIntK8sCluster: str = "ArgoCds"
apiGroupArgoCdIntK8sCluster: str = "int.k8s.cluster.grivit.cloud"
apiVersionArgoCdIntK8sCluster: str = "v1alpha1"

xrArgoCdIntK8sCluster: XrArgoCdIntK8sCluster = XrArgoCdIntK8sCluster {
    _nameSingular = nameSingularArgoCdIntK8sCluster
    _apiGroup = apiGroupArgoCdIntK8sCluster
    _apiVersion = apiVersionArgoCdIntK8sCluster
}

xrdArgoCdIntK8sCluster: XrdArgoCdIntK8sCluster = XrdArgoCdIntK8sCluster {
    _nameSingular = nameSingularArgoCdIntK8sCluster
    _namePlural = namePluralArgoCdIntK8sCluster
    _apiGroup = apiGroupArgoCdIntK8sCluster
    _apiVersion = apiVersionArgoCdIntK8sCluster
}

manifests.yaml_stream([
    xrArgoCdIntK8sCluster
    xrdArgoCdIntK8sCluster
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
