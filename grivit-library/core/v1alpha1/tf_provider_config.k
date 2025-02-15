schema TfProviderConfig:
    _name: str
    _configuration: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "tf.upbound.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: TfProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: TfProviderConfigSpec {
        configuration = _configuration
        credentials = [
            {
                secretRef = {
                    key = "value"
                    name = _credentialsSecretName
                    namespace = _credentialsSecretNamespace
                }
            }
        ]
    }

schema TfProviderConfigMetadata:
    annotations: TfProviderConfigMetadataAnnotations
    name: str

schema TfProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema TfProviderConfigSpec:
    configuration: str
    credentials: [TfProviderConfigSpecCredentials]

schema TfProviderConfigSpecCredentials:
    filename: str = "terraform.tfvars.json"
    secretRef: TfProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema TfProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

