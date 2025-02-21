schema AwsIamUserPolicyAttachmentWrapper:
    _name: str
    _policyArn: str
    _projectNamespace: str
    _userName: str

    managedResource: ManagedResource {
        apiVersion = "iam.aws.upbound.io/v1beta1"
        kind = "UserPolicyAttachment"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.policyArn = _policyArn
        spec.forProvider.user = _userName
        spec.providerConfigRef.name = "${_projectNamespace}-aws"
    }
    usages: [Usage] = []

