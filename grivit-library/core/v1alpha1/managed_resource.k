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
    [str]: str
    "krm.kcl.dev/composition-resource-name": str

schema ManagedResourceMetadataLabels:
    [str]: str

schema ManagedResourceSpec:
    deletionPolicy?: "Delete" | "Orphan"
    forProvider: any
    managementPolicies?: ["Create" | "Delete" | "LateInitialize" | "Observe" | "Update"]
    providerConfigRef: ManagedResourceSpecProviderConfigRef
    readiness?: ManagedResourceSpecReadiness
    references?: any
    writeConnectionSecretToRef?: ManagedResourceSpecWriteConnectionSecretToRef
    publishConnectionDetailsTo?: ManagedResourceSpecPublishConnectionDetailsTo

schema ManagedResourceSpecProviderConfigRef:
    name: str

schema ManagedResourceSpecReadiness:
    celQuery?: str
    policy: str

schema ManagedResourceSpecWriteConnectionSecretToRef:
    name: str
    namespace?: str

schema ManagedResourceSpecPublishConnectionDetailsTo:
    name: str
