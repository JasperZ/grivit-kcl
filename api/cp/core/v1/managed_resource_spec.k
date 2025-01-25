schema ManagedResourceSpec:
    forProvider: any
    providerConfigRef: ManagedResourceSpecProviderConfigRef
    readiness?: ManagedResourceSpecReadiness
    writeConnectionSecretToRef?: ManagedResourceSpecWriteConnectionSecretToRef

