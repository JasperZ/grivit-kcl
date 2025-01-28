import manifests
import core.v1alpha1 as core

nameSingular: str = "Stage"
namePlural: str = "Stages"
apiGroup: str = "os.grivit.cloud"
apiVersion: str = "v1alpha1"

xr: core.OsStageXr = core.OsStageXr {
    _nameSingular = nameSingular
    _apiGroup = apiGroup
    _apiVersion = apiVersion
}

xrd: core.OsStageXrd = core.OsStageXrd {
    _nameSingular = nameSingular
    _namePlural = namePlural
    _apiGroup = apiGroup
    _apiVersion = apiVersion
}

manifests.yaml_stream([xr, xrd], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
