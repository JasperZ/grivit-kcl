schema CpCompositeResourceDefinition:
    apiVersion: "apiextensions.crossplane.io/v1" = "apiextensions.crossplane.io/v1"
    kind: "CompositeResourceDefinition" = "CompositeResourceDefinition"
    metadata: CpCompositeResourceDefinitionMetadata
    spec: CpCompositeResourceDefinitionSpec

schema CpCompositeResourceDefinitionMetadata:
    annotations: CpCompositeResourceDefinitionMetadataAnnotations = {}
    name: str

schema CpCompositeResourceDefinitionMetadataAnnotations:
    [str]: str

schema CpCompositeResourceDefinitionSpec:
    defaultCompositeDeletePolicy: str = "Background"
    group: str
    names: CpCompositeResourceDefinitionSpecNames
    claimNames: CpCompositeResourceDefinitionSpecClaimNames
    versions: [any]

schema CpCompositeResourceDefinitionSpecNames:
    kind: str
    plural: str

schema CpCompositeResourceDefinitionSpecClaimNames:
    kind: str
    plural: str

