import json
import core.v1alpha1 as core

schema OpenBaoProject:
    _observedComposedResources: any
    _openBaoDomain: str
    _openBaoInstanceName: str
    _openBaoInstanceOwnerProjectName: str
    _projectName: str
    _projectNamespace: str

    providerConfigPolicy: core.OpenBaoPolicyWrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-crossplane-provider"
        _policyName = "${_projectName}-crossplane-provider"
        _policyDocument = """\
path "${_projectName}/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list", "scan"]
}

# Allow creating tokens
path "auth/token/create" {
  capabilities = ["update"]
}

# Allow creating tokens with a role
path "auth/token/create/*" {
  capabilities = ["update"]
}

# Allow reading token roles
path "auth/token/roles/*" {
  capabilities = ["read", "list"]
}
"""
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    kvMount: core.OpenBaoMountWrapper {
        _mountType= "kv-v2"
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-kv-mount"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
    }

    kvSecretBackend: core.OpenBaoKvSecretBackendV2Wrapper {
        _instanceName = _openBaoInstanceName
        _instanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _name = "${_projectName}-kv-secret-backendv2"
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _uses = [
            kvMount.managedResource
        ]
    }

    providerConfigToken: core.OpenBaoTokenWrapper {
        _name = "${_projectName}-openbao-crossplane-provider"
        _openBaoInstanceName = _openBaoInstanceName
        _openBaoInstanceOwnerProjectName = _openBaoInstanceOwnerProjectName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _tokenDisplayName= "${_projectName}-openbao-crossplane-provider"
        _tokenPolicies= [providerConfigPolicy.managedResource.spec.forProvider.name]
        _uses = [
            providerConfigPolicy.managedResource
        ]
    }

    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = core.openBaoProviderConfigSecretName(_projectName, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = core.openBaoProviderConfigSecretName(_projectName, _openBaoInstanceName, _openBaoInstanceOwnerProjectName, _projectName)
        _stringData = {
            value = json.encode({
                token = providerConfigToken.getClientToken(_observedComposedResources)
            })
        }
        _uses = [
            providerConfigToken.managedResource
        ]
    }
    
    providerConfig: core.OpenBaoProviderConfigWrapper {
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _openBaoDomain = _openBaoDomain
        _openBaoInstanceContext = _projectName
        _openBaoInstanceName= _openBaoInstanceName
        _openBaoInstanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _projectName = _projectName
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }

    k8sTestSecret: core.K8sObjectSecretWrapper {
        _clusterName = "ctrl"
        _name = "k8s-test-secret"
        _namespace = _projectNamespace
        _projectNamespace = _projectNamespace
        _secretName = "test-secret"
        _stringData = {
            value = json.encode({
                key1: "value1"
                key2: "value2"
                key3: "value3"
            })
        }
    }

    baoTestSecret: core.OpenBaoKvSecretV2Wrapper {
        _name = "bao-test-secret"
        _openBaoInstanceName= _openBaoInstanceName
        _openBaoInstanceOwnerProjectName= _openBaoInstanceOwnerProjectName
        _projectName = _projectName
        _projectNamespace = _projectNamespace
        _secretDataJsonSecretRefKey = "value"
        _secretDataJsonSecretRefName = k8sTestSecret.managedResource.spec.forProvider.manifest.metadata.name
        _secretDataJsonSecretRefNamespace = k8sTestSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _secretName = "test-secret"
    }

    managedResources: [core.ManagedResource | core.OpenBaoProviderConfig] = [
        providerConfigPolicy.managedResource
        kvMount.managedResource
        kvSecretBackend.managedResource
        providerConfigToken.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        k8sTestSecret.managedResource
        baoTestSecret.managedResource
    ]

    usages: [core.Usage] = sum([
        providerConfigPolicy.usages
        kvMount.usages
        kvSecretBackend.usages
        providerConfigToken.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        k8sTestSecret.usages
        baoTestSecret.usages
    ], [])