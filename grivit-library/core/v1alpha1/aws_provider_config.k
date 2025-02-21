schema AwsProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "aws.upbound.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: AwsProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: AwsProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema AwsProviderConfigMetadata:
    annotations: AwsProviderConfigMetadataAnnotations
    name: str

schema AwsProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema AwsProviderConfigSpec:
    credentials: AwsProviderConfigSpecCredentials

schema AwsProviderConfigSpecCredentials:
    secretRef: AwsProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema AwsProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

