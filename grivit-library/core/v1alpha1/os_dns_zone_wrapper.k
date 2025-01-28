schema OsDnsZoneWrapper:
    _targetOsProviderConfig: OsProviderConfigWrapper
    _name: str
    _domain: str
    _email: str
    _uses: [ManagedResource | OsProviderConfig] = []

    managedResource: ManagedResource {
        apiVersion = "dns.openstack.crossplane.io/v1alpha1"
        kind = "ZoneV2"
        metadata.name = _name
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = _name
        }
        spec.forProvider.description = "Zone '${_domain}' managed by Crossplane"
        spec.forProvider.email = _email
        spec.forProvider.name = "${_domain}."
        spec.forProvider.ttl = 30
        spec.forProvider.type = "PRIMARY"
        spec.providerConfigRef.name = _targetOsProviderConfig.managedResource.metadata.name
    }
    usages: [Usage] = []

