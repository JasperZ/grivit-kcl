schema KcProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "keycloak.crossplane.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: KcProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: KcProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema KcProviderConfigMetadata:
    annotations: KcProviderConfigMetadataAnnotations
    name: str

schema KcProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema KcProviderConfigSpec:
    credentials: KcProviderConfigSpecCredentials

schema KcProviderConfigSpecCredentials:
    secretRef: KcProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema KcProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

