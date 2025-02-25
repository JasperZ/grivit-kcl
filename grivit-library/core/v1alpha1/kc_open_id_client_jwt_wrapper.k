import crypto
import json

schema KcOpenIdClientJwtWrapper:
    _clientId: str
    _clientSecret: str
    _domain: str
    _name: str
    _realmId: str
    _projectNamespace: str
    _uses: [ManagedResource] = []

    _configMd5 = crypto.md5("${_clientId}${_clientSecret}")

    managedResource: ManagedResource {
        apiVersion = "http.crossplane.io/v1alpha2"
        kind = "DisposableRequest"
        metadata.name = "${_name}-${_configMd5}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-${_configMd5}"
        }
        spec.deletionPolicy = "Orphan"
        spec.forProvider = {
            body = "grant_type=client_credentials&client_id=${_clientId}&client_secret=${_clientSecret}&scope=openid"
            expectedResponse = ".statusCode == 200"
            headers = {
                "Content-Type" = ["application/x-www-form-urlencoded"]
                "Accept" = ["application/json"]
            }
            method = "POST"
            nextReconcile: "4m"
            shouldLoopInfinitely = True
            url = "https://${_domain}/realms/${_realmId}/protocol/openid-connect/token"
        }
        spec.providerConfigRef.name = "${_projectNamespace}-http"
    }
    usages: [Usage] = [Usage {
        metadata.name = "${_name}-uses-${ofResource.metadata.name}"
        metadata.annotations = {
            "krm.kcl.dev/composition-resource-name" = "${_name}-uses-${ofResource.metadata.name}"
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
                _body = str(observedComposedResources[managedResource.metadata.name].Resource?.status?.response?.body or "")
                _accessToken = json.decode(_body).access_token


        _accessToken
    }

