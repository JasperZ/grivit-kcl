schema ProviderConfig:
    _name: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str

    apiVersion: str = "kubernetes.crossplane.io/v1alpha1"
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

