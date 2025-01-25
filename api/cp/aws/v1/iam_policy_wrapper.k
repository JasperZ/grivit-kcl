import api.cp.core.v1 as cpCore

schema IamPolicyWrapper:
    _controlPlaneAwsProviderConfigName: str
    _description: str
    _name: str
    _policy: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "iam.aws.upbound.io/v1beta1"
        kind = "Policy"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.description = _description
        spec.forProvider.policy = _policy
        spec.providerConfigRef.name = _controlPlaneAwsProviderConfigName
    }
    usages: [cpCore.Usage] = []

