import api.cp.core.v1 as cpCore

schema OsIdentityApplicationCredentialWrapper:
    _name: str
    _tenantNamespace: str
    _targetOsProviderConfigName: str

    managedResource: cpCore.ManagedResource {
        apiVersion = "identity.openstack.crossplane.io/v1alpha1"
        kind = "ApplicationCredentialV3"
        metadata.name = _name
        spec.forProvider.name = _name
        spec.forProvider.roles = ["admin"]
        spec.providerConfigRef.name = _targetOsProviderConfigName
        spec.writeConnectionSecretToRef.name = _name + "-conn"
        spec.writeConnectionSecretToRef.namespace = _tenantNamespace
    }
    usages: [cpCore.Usage] = []

