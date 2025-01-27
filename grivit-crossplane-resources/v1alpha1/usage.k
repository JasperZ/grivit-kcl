schema Usage:
    apiVersion: "apiextensions.crossplane.io/v1alpha1" = "apiextensions.crossplane.io/v1alpha1"
    kind: "Usage" = "Usage"
    metadata: UsageMetadata
    spec: UsageSpec

schema UsageSpec:
    by: UsageSpecResource
    of: UsageSpecResource
    replayDeletion: bool

schema UsageMetadata:
    annotations: UsageMetadataAnnotations
    name: str

schema UsageMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str

schema UsageSpecResource:
    apiVersion: str
    kind: str
    resourceRef: UsageSpecResourceResourceRef

schema UsageSpecResourceResourceRef:
    name: str

