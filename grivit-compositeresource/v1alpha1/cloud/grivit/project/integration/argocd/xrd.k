import grivit_library.core.v1alpha1 as core

schema XrdArgoCdProjectIntegration(core.CompositeResourceDefinition):
    _nameSingular: str
    _namePlural: str
    _apiGroup: str
    _apiVersion: str

    metadata = {
        name = "x${_namePlural}.${_apiGroup}".lower()
    }
    spec = {
        group = _apiGroup
        names.kind = "x${_nameSingular}"
        names.plural = "x${_namePlural}".lower()
        claimNames.kind = _nameSingular
        claimNames.plural = _namePlural.lower()
        versions = [
            {
                name = _apiVersion
                served = True
                referenceable = True
                schema = {
                    openAPIV3Schema = {
                        type = "object"
                        properties = {
                            spec = {
                                type = "object"
                                default = {}
                                properties = {
                                    argoCdDomain = {
                                        type = "string"
                                    }
                                    argoCdInstanceName = {
                                        type = "string"
                                    }
                                    argoCdInstanceOwnerProjectName = {
                                        type = "string"
                                    }
                                    keycloakDomain = {
                                        type = "string"
                                    }
                                    keycloakInstanceName = {
                                        type = "string"
                                    }
                                    keycloakInstanceOwnerProjectName = {
                                        type = "string"
                                    }
                                    targetProjectName = {
                                        type = "string"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ]
    }

