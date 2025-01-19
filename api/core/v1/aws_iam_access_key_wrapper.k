schema AwsIamAccessKeyWrapper:
    _controlPlaneAwsProviderConfigName: str
    _name: str
    _awsIamUserWrapper: AwsIamUserWrapper
    _tenantNamespace: str

    managedResource: CpManagedResource {
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
    usages: [CpUsage] = []

