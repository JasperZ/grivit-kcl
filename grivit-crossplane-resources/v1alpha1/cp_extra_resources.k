schema CpExtraResources:
    apiVersion: str = "meta.krm.kcl.dev/v1alpha1"
    kind: str = "ExtraResources"
    requirements: CpExtraResourcesRequirements

schema CpExtraResourcesRequirements:
    [requirement: str]: CpExtraResourcesRequirement

schema CpExtraResourcesRequirement:
    apiVersion: str
    kind: str
    matchName?: str
    matchLabels?: CpExtraResourcesRequirementMatchLabels

schema CpExtraResourcesRequirementMatchLabels:
    [str]: str

