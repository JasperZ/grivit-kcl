schema HttpProviderConfig:
    _name: str

    apiVersion: str = "keycloak.crossplane.io/v1beta1"
    kind: str = "ProviderConfig"
    metadata: HttpProviderConfigMetadata {
        annotations: HttpProviderConfigMetadataAnnotations {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: HttpProviderConfigSpec 

schema HttpProviderConfigMetadata:
    annotations: HttpProviderConfigMetadataAnnotations
    labels?: HttpProviderConfigMetadataLabels
    name: str

schema HttpProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema HttpProviderConfigMetadataLabels:
    [str]: str

schema HttpProviderConfigSpec:
    credentials: HttpProviderConfigSpecCredentials

schema HttpProviderConfigSpecCredentials:
    source: "None" | "Secret" = "None"
    secretRef?: HttpProviderConfigSpecCredentialsSecretRef

schema HttpProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

