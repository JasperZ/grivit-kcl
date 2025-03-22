schema OpenBaoProviderConfig:
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _name: str

    apiVersion: str = "vault.upbound.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: OpenBaoProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: OpenBaoProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema OpenBaoProviderConfigMetadata:
    annotations: OpenBaoProviderConfigMetadataAnnotations
    name: str

schema OpenBaoProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema OpenBaoProviderConfigSpec:
    credentials: OpenBaoProviderConfigSpecCredentials
    serverAddr: str

schema OpenBaoProviderConfigSpecCredentials:
    secretRef: OpenBaoProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema OpenBaoProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

