schema Composition:
    apiVersion: "apiextensions.crossplane.io/v1" = "apiextensions.crossplane.io/v1"
    kind: "Composition" = "Composition"
    metadata: CompositionMetadata
    spec: CompositionSpec

schema CompositionMetadata:
    annotations?: CompositionMetadataAnnotations
    name: str

schema CompositionMetadataAnnotations:
    [str]: str

schema CompositionSpec:
    compositeTypeRef: CompositionSpecCompositeTypeRef
    mode: str = "Pipeline"
    pipeline: [CompositionSpecPipelineStepKcl | CompositionSpecPipelineStepAutoReady] = []

schema CompositionSpecCompositeTypeRef:
    apiVersion: str
    kind: str

schema CompositionSpecPipelineStepKcl:
    step: str
    functionRef: CompositionSpecPipelineStepKclFunctionRef = {}
    input: CompositionSpecPipelineStepKclInput

schema CompositionSpecPipelineStepKclInput:
    apiVersion: str = "krm.kcl.dev/v1alpha1"
    kind: str = "KCLInput"
    metadata: CompositionSpecPipelineStepKclInputMetadata = {}
    spec: CompositionSpecPipelineStepKclInputSpec

schema CompositionSpecPipelineStepKclInputSpec:
    dependencies: str = ""
    source: str = ""

schema CompositionSpecPipelineStepKclInputMetadata:
    name: str = "basic"

schema CompositionSpecPipelineStepKclFunctionRef:
    name: "function-kcl" = "function-kcl"

schema CompositionSpecPipelineStepAutoReady:
    step: str
    functionRef: CompositionSpecPipelineStepAutoReadyFunctionRef = {}

schema CompositionSpecPipelineStepAutoReadyFunctionRef:
    name: "function-auto-ready" = "function-auto-ready"

