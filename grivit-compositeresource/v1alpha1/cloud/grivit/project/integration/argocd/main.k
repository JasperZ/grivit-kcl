import manifests

nameSingular: str = "ArgoCd"
namePlural: str = "ArgoCds"
apiGroup: str = "integration.project.grivit.cloud"
apiVersion: str = "v1alpha1"

xrArgoCdProjectIntegration: XrArgoCdProjectIntegration = XrArgoCdProjectIntegration {
    _nameSingular = nameSingular
    _apiGroup = apiGroup
    _apiVersion = apiVersion
}

xrdArgoCdProjectIntegration: XrdArgoCdProjectIntegration = XrdArgoCdProjectIntegration {
    _nameSingular = nameSingular
    _namePlural = namePlural
    _apiGroup = apiGroup
    _apiVersion = apiVersion
}

manifests.yaml_stream([
    xrArgoCdProjectIntegration
    xrdArgoCdProjectIntegration
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
