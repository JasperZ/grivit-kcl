schema OsProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "openstack.crossplane.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: OsProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: OsProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema OsProviderConfigMetadata:
    annotations: OsProviderConfigMetadataAnnotations
    name: str

schema OsProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema OsProviderConfigSpec:
    credentials: OsProviderConfigSpecCredentials

schema OsProviderConfigSpecCredentials:
    secretRef: OsProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema OsProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

