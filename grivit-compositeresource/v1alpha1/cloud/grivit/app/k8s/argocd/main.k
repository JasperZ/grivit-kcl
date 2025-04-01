import manifests

nameSingularArgoCdAppK8s: str = "ArgoCd"
namePluralArgoCdAppK8s: str = "ArgoCds"
apiGroupArgoCdAppK8s: str = "k8s.app.grivit.cloud"
apiVersionArgoCdAppK8s: str = "v1alpha1"

xrArgoCdAppK8s: XrArgoCdAppK8s = XrArgoCdAppK8s {
    _nameSingular = nameSingularArgoCdAppK8s
    _apiGroup = apiGroupArgoCdAppK8s
    _apiVersion = apiVersionArgoCdAppK8s
}

xrdArgoCdAppK8s: XrdArgoCdAppK8s = XrdArgoCdAppK8s {
    _nameSingular = nameSingularArgoCdAppK8s
    _namePlural = namePluralArgoCdAppK8s
    _apiGroup = apiGroupArgoCdAppK8s
    _apiVersion = apiVersionArgoCdAppK8s
}

manifests.yaml_stream([
    xrArgoCdAppK8s
    xrdArgoCdAppK8s
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
