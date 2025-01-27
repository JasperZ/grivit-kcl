import base64

schema AwsIamAccessKeyWrapper:
    _controlPlaneAwsProviderConfigName: str
    _name: str
    _awsIamUserWrapper: AwsIamUserWrapper
    _tenantNamespace: str

    managedResource: ManagedResource {
        apiVersion = "iam.aws.upbound.io/v1beta1"
        kind = "AccessKey"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.user = _awsIamUserWrapper.managedResource.metadata.name
        spec.providerConfigRef.name = _controlPlaneAwsProviderConfigName
        spec.writeConnectionSecretToRef.name = _name
        spec.writeConnectionSecretToRef.namespace = _tenantNamespace
    }
    usages: [Usage] = []

    getAccessKeyId: (any) -> str = lambda observedCompositeResource: any -> str {
        _accessKeyId: str = ""
        if managedResource.metadata.name in observedCompositeResource:
            _accessKeyId = str(base64.decode(observedCompositeResource[managedResource.metadata.name].ConnectionDetails?.username))

        _accessKeyId
    }

    getAccessKeySecret: (any) -> str = lambda observedCompositeResource: any -> str {
        _accessKeySecret: str = ""
        if managedResource.metadata.name in observedCompositeResource:
            _accessKeySecret = str(base64.decode(observedCompositeResource[managedResource.metadata.name].ConnectionDetails?.password))

        _accessKeySecret
    }

