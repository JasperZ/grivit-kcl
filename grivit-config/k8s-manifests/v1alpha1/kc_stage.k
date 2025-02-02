import core.v1alpha1 as core

kcStageNameSingular: str = "Stage"
kcStageNamePlural: str = "Stages"
kcStageApiGroup: str = "kc.grivit.cloud"
kcStageApiVersion: str = "v1alpha1"

kcStageXr: core.KcStageXr = core.KcStageXr {
    _nameSingular = kcStageNameSingular
    _apiGroup = kcStageApiGroup
    _apiVersion = kcStageApiVersion
}

kcStageXrd: core.KcStageXrd = core.KcStageXrd {
    _nameSingular = kcStageNameSingular
    _namePlural = kcStageNamePlural
    _apiGroup = kcStageApiGroup
    _apiVersion = kcStageApiVersion
}
