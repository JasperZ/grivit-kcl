schema ExtraResources:
    apiVersion: str = "meta.krm.kcl.dev/v1alpha1"
    kind: str = "ExtraResources"
    requirements: ExtraResourcesRequirements

schema ExtraResourcesRequirements:
    [requirement: str]: ExtraResourcesRequirement

schema ExtraResourcesRequirement:
    apiVersion: str
    kind: str
    matchName?: str
    matchLabels?: ExtraResourcesRequirementMatchLabels

schema ExtraResourcesRequirementMatchLabels:
    [str]: str

