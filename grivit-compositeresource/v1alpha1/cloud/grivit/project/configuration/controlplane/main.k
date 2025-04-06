import manifests

nameSingularControlPlaneProject: str = "ControlPlane"
namePluralControlPlaneProject: str = "ControlPlanes"
apiGroupControlPlaneProject: str = "configuration.project.grivit.cloud"
apiVersionControlPlaneProject: str = "v1alpha1"

xrControlPlaneProject: XrControlPlaneProject = XrControlPlaneProject {
    _nameSingular = nameSingularControlPlaneProject
    _apiGroup = apiGroupControlPlaneProject
    _apiVersion = apiVersionControlPlaneProject
}

xrdControlPlaneProject: XrdControlPlaneProject = XrdControlPlaneProject {
    _nameSingular = nameSingularControlPlaneProject
    _namePlural = namePluralControlPlaneProject
    _apiGroup = apiGroupControlPlaneProject
    _apiVersion = apiVersionControlPlaneProject
}

manifests.yaml_stream([
    xrControlPlaneProject
    xrdControlPlaneProject
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
