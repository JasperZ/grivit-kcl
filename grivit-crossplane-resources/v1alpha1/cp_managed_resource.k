schema CpManagedResource:
    apiVersion: str
    kind: str
    metadata: CpManagedResourceMetadata
    spec: CpManagedResourceSpec

schema CpManagedResourceMetadata:
    annotations: CpManagedResourceMetadataAnnotations
    labels?: CpManagedResourceMetadataLabels
    name: str

schema CpManagedResourceMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str

schema CpManagedResourceMetadataLabels:
    [str]: str

schema CpManagedResourceSpec:
    forProvider: any
    providerConfigRef: CpManagedResourceSpecProviderConfigRef
    readiness?: CpManagedResourceSpecReadiness
    writeConnectionSecretToRef?: CpManagedResourceSpecWriteConnectionSecretToRef

schema CpManagedResourceSpecProviderConfigRef:
    name: str

schema CpManagedResourceSpecReadiness:
    celQuery?: str
    policy: str

schema CpManagedResourceSpecWriteConnectionSecretToRef:
    name: str
    namespace?: str

