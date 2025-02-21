schema HelmProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "helm.crossplane.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: HelmProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: HelmProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema HelmProviderConfigMetadata:
    annotations: HelmProviderConfigMetadataAnnotations
    name: str

schema HelmProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema HelmProviderConfigSpec:
    credentials: HelmProviderConfigSpecCredentials

schema HelmProviderConfigSpecCredentials:
    secretRef: HelmProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema HelmProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

