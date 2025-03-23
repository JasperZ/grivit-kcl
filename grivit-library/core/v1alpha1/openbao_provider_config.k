schema OpenBaoProviderConfig:
    _credentialsSecretKey: str = "value"
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _openBaoDomain: str
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
                key = _credentialsSecretKey
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
        address = "https://${_openBaoDomain}:443"
    }

schema OpenBaoProviderConfigMetadata:
    annotations: OpenBaoProviderConfigMetadataAnnotations
    name: str

schema OpenBaoProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema OpenBaoProviderConfigSpec:
    address: str
    credentials: OpenBaoProviderConfigSpecCredentials

schema OpenBaoProviderConfigSpecCredentials:
    secretRef: OpenBaoProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema OpenBaoProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

