schema OsProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "openstack.crossplane.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: ProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: ProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema ProviderConfigMetadata:
    annotations: ProviderConfigMetadataAnnotations
    name: str

schema ProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema ProviderConfigSpec:
    credentials: ProviderConfigSpecCredentials

schema ProviderConfigSpecCredentials:
    secretRef: ProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema ProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

