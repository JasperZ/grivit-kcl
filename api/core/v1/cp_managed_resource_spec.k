schema CpManagedResourceSpec:
    forProvider: any
    providerConfigRef: CpManagedResourceSpecProviderConfigRef
    readiness?: CpManagedResourceSpecReadiness
    writeConnectionSecretToRef?: CpManagedResourceSpecWriteConnectionSecretToRef

