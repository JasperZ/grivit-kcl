import api.cp.core.v1 as cpCore

schema IamUserWrapper:
    _controlPlaneAwsProviderConfigName: str
    _name: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "iam.aws.upbound.io/v1beta1"
        kind = "User"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider = {}
        spec.providerConfigRef.name = _controlPlaneAwsProviderConfigName
    }
    usages: [cpCore.Usage] = []

