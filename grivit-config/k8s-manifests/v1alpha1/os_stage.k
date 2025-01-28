import core.v1alpha1 as core

osStageNameSingular: str = "Stage"
osStageNamePlural: str = "Stages"
osStageApiGroup: str = "os.grivit.cloud"
osStageApiVersion: str = "v1alpha1"

osStageXr: core.OsStageXr = core.OsStageXr {
    _nameSingular = osStageNameSingular
    _apiGroup = osStageApiGroup
    _apiVersion = osStageApiVersion
}

osStageXrd: core.OsStageXrd = core.OsStageXrd {
    _nameSingular = osStageNameSingular
    _namePlural = osStageNamePlural
    _apiGroup = osStageApiGroup
    _apiVersion = osStageApiVersion
}
