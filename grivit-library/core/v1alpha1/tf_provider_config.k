schema TfProviderConfig:
    _name: str
    _configuration: str

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
    }

schema TfProviderConfigMetadata:
    annotations: TfProviderConfigMetadataAnnotations
    name: str

schema TfProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema TfProviderConfigSpec:
    configuration: str

