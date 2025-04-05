import crypto
import json

schema KcOpenIdClientJwtWrapper:
    _keycloakInstance: KeycloakInstance
    _keycloakClientId: str
    _keycloakClientSecret: str
    _managedResourceName: str
    _projectName: str
    _uses: [ManagedResource] = []

    _configMd5 = crypto.md5("${_keycloakClientId}${_keycloakClientSecret}")

    managedResource: ManagedResource {
        apiVersion = "http.crossplane.io/v1alpha2"
        kind = "DisposableRequest"
        metadata.name = "${_managedResourceName}-${_configMd5}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_managedResourceName}-${_configMd5}"
        }
        spec.deletionPolicy = "Orphan"
        spec.forProvider = {
            body = "grant_type=client_credentials&client_id=${_keycloakClientId}&client_secret=${_keycloakClientSecret}&scope=openid"
            expectedResponse = ".statusCode == 200"
            headers = {
                "Content-Type" = ["application/x-www-form-urlencoded"]
                "Accept" = ["application/json"]
            }
            method = "POST"
            nextReconcile: "4m"
            shouldLoopInfinitely = True
            url = "https://${_keycloakInstance.domain}/realms/${_keycloakInstance.realmId}/protocol/openid-connect/token"
        }
        spec.providerConfigRef.name = httpProviderConfigName(_projectName)
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_managedResourceName}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_managedResourceName}-uses-${ofResource.metadata.name}"
        }
        spec.by.apiVersion = managedResource.apiVersion
        spec.by.kind = managedResource.kind
        spec.by.resourceRef.name = managedResource.metadata.name
        spec.of.apiVersion = ofResource.apiVersion
        spec.of.kind = ofResource.kind
        spec.of.resourceRef.name = ofResource.metadata.name
    } for ofResource in _uses]

    getAccessToken: (any) -> str = lambda observedComposedResources: any -> str {
        _accessToken: str = ""

        if managedResource.metadata.name in observedComposedResources:
            if observedComposedResources[managedResource.metadata.name].Resource?.status?.response?.body:
                _bodyRaw = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.response?.body or "")
                if json.validate(_bodyRaw):
                    _bodyJson = json.decode(_bodyRaw)
                    if _bodyJson.access_token:
                        _accessToken = _bodyJson.access_token




        _accessToken
    }

