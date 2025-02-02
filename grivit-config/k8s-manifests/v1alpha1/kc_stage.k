import core.v1alpha1 as core

kcStageNameSingular: str = "Stage"
kcStageNamePlural: str = "Stages"
kcStageApiGroup: str = "kc.grivit.cloud"
kcStageApiVersion: str = "v1alpha1"

kcStageXr: core.OsStageXr = core.OsStageXr {
    _nameSingular = kcStageNameSingular
    _apiGroup = kcStageApiGroup
    _apiVersion = kcStageApiVersion
}

kcStageXrd: core.OsStageXrd = core.OsStageXrd {
    _nameSingular = kcStageNameSingular
    _namePlural = kcStageNamePlural
    _apiGroup = kcStageApiGroup
    _apiVersion = kcStageApiVersion
}
