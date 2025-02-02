schema ManagedResource:
    apiVersion: str
    kind: str
    metadata: ManagedResourceMetadata
    spec: ManagedResourceSpec

schema ManagedResourceMetadata:
    annotations: ManagedResourceMetadataAnnotations
    labels?: ManagedResourceMetadataLabels
    name: str

schema ManagedResourceMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str

schema ManagedResourceMetadataLabels:
    [str]: str

schema ManagedResourceSpec:
    forProvider: any
    managementPolicies?: [str]
    providerConfigRef: ManagedResourceSpecProviderConfigRef
    readiness?: ManagedResourceSpecReadiness
    writeConnectionSecretToRef?: ManagedResourceSpecWriteConnectionSecretToRef

schema ManagedResourceSpecProviderConfigRef:
    name: str

schema ManagedResourceSpecReadiness:
    celQuery?: str
    policy: str

schema ManagedResourceSpecWriteConnectionSecretToRef:
    name: str
    namespace?: str

