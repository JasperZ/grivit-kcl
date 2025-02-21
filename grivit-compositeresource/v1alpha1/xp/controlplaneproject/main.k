import manifests

nameSingular: str = "ControlPlaneProject"
namePlural: str = "ControlPlaneProjects"
apiGroup: str = "xp.grivit.cloud"
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
