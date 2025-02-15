import grivit_library.core.v1alpha1 as core

schema Xrd(core.CompositeResourceDefinition):
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
                                    adminPassword = {
                                        type = "string"
                                    }
                                    controlPlaneK8sProviderConfigName = {
                                        type = "string"
                                    }
                                    domain = {
                                        type = "string"
                                    }
                                    k8sClusterClaimRef = {
                                        type = "object"
                                        properties = {
                                            name = {
                                                type = "string"
                                            }
                                        }
                                    }
                                    kcStageClaimRef = {
                                        type = "object"
                                        properties = {
                                            name = {
                                                type = "string"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ]
    }

