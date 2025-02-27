import base64

schema AwsIamAccessKeyWrapper:
    _awsIamUserName: str
    _name: str
    _projectNamespace: str

    managedResource: ManagedResource {
        apiVersion = "iam.aws.upbound.io/v1beta1"
        kind = "AccessKey"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.user = _awsIamUserName
        spec.providerConfigRef.name = awsProviderConfigName(_projectNamespace)
        spec.writeConnectionSecretToRef.name = _name
        spec.writeConnectionSecretToRef.namespace = _projectNamespace
    }
    usages: [Usage] = []

    getAccessKeyId: (any) -> str = lambda observedComposedResources: any -> str {
        _accessKeyId: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _accessKeyId = str(base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails?.username))

        _accessKeyId
    }

    getAccessKeySecret: (any) -> str = lambda observedComposedResources: any -> str {
        _accessKeySecret: str = ""
        if managedResource.metadata.name in observedComposedResources:
            _accessKeySecret = str(base64.decode(observedComposedResources[managedResource.metadata.name].ConnectionDetails?.password))

        _accessKeySecret
    }

