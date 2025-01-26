schema CpComposition:
    apiVersion: "apiextensions.crossplane.io/v1" = "apiextensions.crossplane.io/v1"
    kind: "Composition" = "Composition"
    metadata: CpCompositionMetadata
    spec: CpCompositionSpec

schema CpCompositionMetadata:
    annotations?: CpCompositionMetadataAnnotations
    name: str

schema CpCompositionMetadataAnnotations:
    [str]: str

schema CpCompositionSpec:
    compositeTypeRef: CpCompositionSpecCompositeTypeRef
    mode: str = "Pipeline"
    pipeline: [CpCompositionSpecPipelineStepKcl | CpCompositionSpecPipelineStepAutoReady] = []

schema CpCompositionSpecCompositeTypeRef:
    apiVersion: str
    kind: str

schema CpCompositionSpecPipelineStepKcl:
    step: str
    functionRef: CpCompositionSpecPipelineStepKclFunctionRef = {}
    input: CpCompositionSpecPipelineStepKclInput

schema CpCompositionSpecPipelineStepKclInput:
    apiVersion: str = "krm.kcl.dev/v1alpha1"
    kind: str = "KCLInput"
    metadata: CpCompositionSpecPipelineStepKclInputMetadata = {}
    spec: CpCompositionSpecPipelineStepKclInputSpec

schema CpCompositionSpecPipelineStepKclInputSpec:
    dependencies: str = ""
    source: str = ""

schema CpCompositionSpecPipelineStepKclInputMetadata:
    name: str = "basic"

schema CpCompositionSpecPipelineStepKclFunctionRef:
    name: "function-kcl" = "function-kcl"

schema CpCompositionSpecPipelineStepAutoReady:
    step: str
    functionRef: CpCompositionSpecPipelineStepAutoReadyFunctionRef = {}

schema CpCompositionSpecPipelineStepAutoReadyFunctionRef:
    name: "function-auto-ready" = "function-auto-ready"

