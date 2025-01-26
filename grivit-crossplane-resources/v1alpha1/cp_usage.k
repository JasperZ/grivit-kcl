schema CpUsage:
    apiVersion: "apiextensions.crossplane.io/v1alpha1" = "apiextensions.crossplane.io/v1alpha1"
    kind: "Usage" = "Usage"
    metadata: CpUsageMetadata
    spec: CpUsageSpec

schema CpUsageSpec:
    by: CpUsageSpecResource
    of: CpUsageSpecResource
    replayDeletion: bool

schema CpUsageMetadata:
    annotations: CpUsageMetadataAnnotations
    name: str

schema CpUsageMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str

schema CpUsageSpecResource:
    apiVersion: str
    kind: str
    resourceRef: CpUsageSpecResourceResourceRef

schema CpUsageSpecResourceResourceRef:
    name: str

