import grivit_library.core.v1alpha1 as glcore

schema OsStageXrd(glcore.CompositeResourceDefinition):
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
                                    controlPlaneK8sProviderConfigName = {
                                        type = "string"
                                    }
                                    controlPlaneOsProviderConfigName = {
                                        type = "string"
                                    }
                                    projectName = {
                                        type = "string"
                                    }
                                    domain = {
                                        type = "string"
                                    }
                                    email = {
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

