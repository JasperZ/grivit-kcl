import manifests

nameSingular: str = "Stage"
namePlural: str = "Stages"
apiGroup: str = "kc.grivit.cloud"
apiVersion: str = "v1alpha1"

xr: Xr = Xr {
    _nameSingular = nameSingular
    _apiGroup = apiGroup
    _apiVersion = apiVersion
}

xrd: Xrd = Xrd {
    _nameSingular = nameSingular
    _namePlural = namePlural
    _apiGroup = apiGroup
    _apiVersion = apiVersion
}

manifests.yaml_stream([
    xr
    xrd
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
