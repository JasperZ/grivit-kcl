schema AwsIamPolicyWrapper:
    _controlPlaneAwsProviderConfigName: str
    _description: str
    _name: str
    _policy: str

    managedResource: ManagedResource {
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
    usages: [Usage] = []

    getPolicyArn: (any) -> str = lambda observedComposedResources: any -> str {
        _awsPolicyArn: str = ""

        if managedResource.metadata.name in observedComposedResources:
            _awsPolicyArn = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.atProvider?.arn or "")

        _awsPolicyArn
    }

