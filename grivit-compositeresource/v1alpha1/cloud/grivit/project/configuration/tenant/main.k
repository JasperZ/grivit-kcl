import manifests

nameSingularTenantProject: str = "Tenant"
namePluralTenantProject: str = "Tenants"
apiGroupTenantProject: str = "configuration.project.grivit.cloud"
apiVersionTenantProject: str = "v1alpha1"

xrTenantProject: XrTenantProject = XrTenantProject {
    _nameSingular = nameSingularTenantProject
    _apiGroup = apiGroupTenantProject
    _apiVersion = apiVersionTenantProject
}

xrdTenantProject: XrdTenantProject = XrdTenantProject {
    _nameSingular = nameSingularTenantProject
    _namePlural = namePluralTenantProject
    _apiGroup = apiGroupTenantProject
    _apiVersion = apiVersionTenantProject
}

manifests.yaml_stream([
    xrTenantProject
    xrdTenantProject
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
