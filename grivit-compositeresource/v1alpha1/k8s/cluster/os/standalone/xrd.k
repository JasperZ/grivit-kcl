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
                                    argoCdDomain = {
                                        type = "string"
                                    }
                                    controlPlaneAwsProviderConfigName = {
                                        type = "string"
                                    }
                                    controlPlaneHelmProviderConfigName = {
                                        type = "string"
                                    }
                                    controlPlaneKcProviderConfigName = {
                                        type = "string"
                                    }
                                    controlPlaneK8sProviderConfigName = {
                                        type = "string"
                                    }
                                    controlPlane = {
                                        type = "object"
                                        default = {}
                                        properties = {
                                            flavor = {
                                                type = "string"
                                                default = "m1.medium"
                                            }
                                            replicas = {
                                                type = "integer"
                                                default = 3
                                                minimum = 1
                                            }
                                            rootVolumeSize = {
                                                type = "integer"
                                                default = 50
                                                minimum = 50
                                            }
                                        }
                                    }
                                    domain = {
                                        type = "string"
                                    }
                                    email = {
                                        type = "string"
                                    }
                                    externalNetworkName = {
                                        type = "string"
                                    }
                                    headlampDomain = {
                                        type = "string"
                                    }
                                    # kcStageClaimRef = {
                                    #     type = "object"
                                    #     properties = {
                                    #         name = {
                                    #             type  = "string"
                                    #         }
                                    #     }
                                    # }
                                    kubernetesVersion = {
                                        type = "string"
                                        pattern = "^v(1.28.13|1.29.8|1.30.4|1.31.0)$"
                                    }
                                    osStageClaimRef = {
                                        type = "object"
                                        properties = {
                                            name = {
                                                type  = "string"
                                            }
                                        }
                                    }
                                    realmId = {
                                        type = "string"
                                    }
                                    workers = {
                                        type = "object"
                                        default = {}
                                        properties = {
                                            autoscaling = {
                                                type = "object"
                                                default = {}
                                                properties = {
                                                    maxSize = {
                                                        type = "integer"
                                                        default = 3
                                                        minimum = 1
                                                    }
                                                    minSize = {
                                                        type = "integer"
                                                        default = 1
                                                        minimum = 1
                                                    }
                                                }
                                            }
                                            flavor = {
                                                type = "string"
                                                default = "m1.medium"
                                            }
                                            rootVolumeSize = {
                                                type = "integer"
                                                default = 50
                                                minimum = 50
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

