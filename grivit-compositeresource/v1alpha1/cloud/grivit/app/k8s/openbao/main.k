import manifests

nameSingularOpenBaoK8sApp: str = "OpenBao"
namePluralOpenBaoK8sApp: str = "OpenBaos"
apiGroupOpenBaoK8sApp: str = "k8s.app.grivit.cloud"
apiVersionOpenBaoK8sApp: str = "v1alpha1"

xrOpenBaoK8sApp: XrOpenBaoK8sApp = XrOpenBaoK8sApp {
    _nameSingular = nameSingularOpenBaoK8sApp
    _apiGroup = apiGroupOpenBaoK8sApp
    _apiVersion = apiVersionOpenBaoK8sApp
}

xrdOpenBaoK8sApp: XrdOpenBaoK8sApp = XrdOpenBaoK8sApp {
    _nameSingular = nameSingularOpenBaoK8sApp
    _namePlural = namePluralOpenBaoK8sApp
    _apiGroup = apiGroupOpenBaoK8sApp
    _apiVersion = apiVersionOpenBaoK8sApp
}

manifests.yaml_stream([
    xrOpenBaoK8sApp
    xrdOpenBaoK8sApp
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
