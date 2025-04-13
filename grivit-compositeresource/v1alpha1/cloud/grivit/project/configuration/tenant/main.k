import manifests

nameSingularTenantProjectConfiguration: str = "Tenant"
namePluralTenantProjectConfiguration: str = "Tenants"
apiGroupTenantProjectConfiguration: str = "configuration.project.grivit.cloud"
apiVersionTenantProjectConfiguration: str = "v1alpha1"

xrTenantProjectConfiguration: XrTenantProjectConfiguration = XrTenantProjectConfiguration {
    _nameSingular = nameSingularTenantProjectConfiguration
    _apiGroup = apiGroupTenantProjectConfiguration
    _apiVersion = apiVersionTenantProjectConfiguration
}

xrdTenantProjectConfiguration: XrdTenantProjectConfiguration = XrdTenantProjectConfiguration {
    _nameSingular = nameSingularTenantProjectConfiguration
    _namePlural = namePluralTenantProjectConfiguration
    _apiGroup = apiGroupTenantProjectConfiguration
    _apiVersion = apiVersionTenantProjectConfiguration
}

manifests.yaml_stream([
    xrTenantProjectConfiguration
    xrdTenantProjectConfiguration
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
