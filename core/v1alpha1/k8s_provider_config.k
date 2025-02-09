schema K8sProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "kubernetes.crossplane.io/v1alpha1"
    kind: str = "ProviderConfig"
    metadata: K8sProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: K8sProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
    }

schema K8sProviderConfigMetadata:
    annotations: K8sProviderConfigMetadataAnnotations
    name: str

schema K8sProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema K8sProviderConfigSpec:
    credentials: K8sProviderConfigSpecCredentials

schema K8sProviderConfigSpecCredentials:
    secretRef: K8sProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema K8sProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

