schema CompositeResourceDefinition:
    apiVersion: "apiextensions.crossplane.io/v1" = "apiextensions.crossplane.io/v1"
    kind: "CompositeResourceDefinition" = "CompositeResourceDefinition"
    metadata: CompositeResourceDefinitionMetadata
    spec: CompositeResourceDefinitionSpec

schema CompositeResourceDefinitionMetadata:
    annotations: CompositeResourceDefinitionMetadataAnnotations = {}
    name: str

schema CompositeResourceDefinitionMetadataAnnotations:
    [str]: str

schema CompositeResourceDefinitionSpec:
    defaultCompositeDeletePolicy: str = "Background"
    group: str
    names: CompositeResourceDefinitionSpecNames
    claimNames: CompositeResourceDefinitionSpecClaimNames
    versions: [any]

schema CompositeResourceDefinitionSpecNames:
    kind: str
    plural: str

schema CompositeResourceDefinitionSpecClaimNames:
    kind: str
    plural: str

