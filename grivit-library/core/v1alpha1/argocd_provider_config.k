schema ArgoCdProviderConfig:
    _argoCdDomain: str
    _credentialsSecretName: str
    _credentialsSecretNamespace: str
    _name: str

    apiVersion: str = "argocd.crossplane.io/v1alpha1"
    kind: str = "ProviderConfig"
    metadata: ArgoCdProviderConfigMetadata {
        annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        name = _name
    }
    spec: ArgoCdProviderConfigSpec {
        credentials = {
            secretRef = {
                key = "value"
                name = _credentialsSecretName
                namespace = _credentialsSecretNamespace
            }
        }
        serverAddr = "${_argoCdDomain}:443"
    }

schema ArgoCdProviderConfigMetadata:
    annotations: ArgoCdProviderConfigMetadataAnnotations
    name: str

schema ArgoCdProviderConfigMetadataAnnotations:
    "krm.kcl.dev/composition-resource-name": str
    "krm.kcl.dev/ready": str = "True"

schema ArgoCdProviderConfigSpec:
    credentials: ArgoCdProviderConfigSpecCredentials
    serverAddr: str

schema ArgoCdProviderConfigSpecCredentials:
    secretRef: ArgoCdProviderConfigSpecCredentialsSecretRef
    source: "Secret" = "Secret"

schema ArgoCdProviderConfigSpecCredentialsSecretRef:
    key: str
    name: str
    namespace: str

