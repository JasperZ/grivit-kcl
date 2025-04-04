import crypto
import json
import core.v1alpha1 as core
import core.v1alpha1.openbao_utils as openBaoUtils

schema K8sAppOperationsOpenBao:
    _clusterName: str
    _domain: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper] = []
    _instanceName: str
    _kcDomain: str
    _kcInstanceName: str
    _kcRealmId: str
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    kcOpenBaoClient: core.KcOpenIdClientOpenBaoWrapper {
        _openBaoDomain = _domain
        _instanceName = _kcInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
    }
    kcOpenBaoClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = kcOpenBaoClient.getAtProviderId(_observedComposedResources)
        _instanceName = _kcInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _name = "${_name}-openbao-client-default-scopes"
        _projectName = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            kcOpenBaoClient.managedResource
        ]
    }
    kcOpenBaoAdminsGroup = core.KcGroupOpenBaoWrapper {
        _groupType = "admins"
        _instanceName = _instanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectName = "admin"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            kcOpenBaoClientDefaultScopes.managedResource
        ]
    }
    k8sServiceAccount: core.K8sObjectServiceAccountWrapper {
        _clusterName = _clusterName
        _name = "${_name}-sa"
        _projectNamespace = _projectNamespace
        _serviceAccountName = "openbao"
        _serviceAccountNamespace = "openbao"
    }
    k8sRole: core.K8sObjectRoleWrapper {
        _clusterName = _clusterName
        _name = "${_name}-role"
        _projectNamespace = _projectNamespace
        _roleName = "openbao"
        _roleNamespace = "openbao"
        _roleRules = [
            {
                apiGroups = [""]
                resources = ["secrets"]
                verbs = ["get", "create", "patch", "update"]
            }
            {
                apiGroups = [""]
                resources = ["pods"]
                verbs = ["get"]
            }
            {
                apiGroups = [""]
                resources = ["pods/exec"]
                verbs = ["create"]
            }
        ]
    }
    k8sRoleBinding: core.K8sObjectRoleBindingWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rolebinding"
        _projectNamespace = _projectNamespace
        _roleBindingName = "openbao"
        _roleBindingNamespace = "openbao"
        _roleBindingSubjects = [
            {
                kind = k8sServiceAccount.managedResource.spec.forProvider.manifest.kind
                name = k8sServiceAccount.managedResource.spec.forProvider.manifest.metadata.name
                namespace = k8sServiceAccount.managedResource.spec.forProvider.manifest.metadata.name
            }
        ]
        _roleBindingRoleRefKind = k8sRole.managedResource.spec.forProvider.manifest.kind
        _roleBindingRoleRefName = k8sRole.managedResource.spec.forProvider.manifest.metadata.name
        _roleBindingRoleRefNamespace = k8sRole.managedResource.spec.forProvider.manifest.metadata.namespace
        _uses = [
            k8sServiceAccount.managedResource
            k8sRole.managedResource
        ]
    }
    k8sScriptsConfigMap: core.K8sObjectConfigMapWrapper {
        _clusterName = _clusterName
        _configMapName = "openbao-scripts"
        _configMapNamespace = "openbao"
        _configMapData = {
            "init-and-unseal.sh": """\
#!/bin/bash

set -euo pipefail

echo "namespace: \${POD_NAMESPACE}"
echo "pod: \${POD_NAME}"

# Set as Pod ENV
#OPENBAO_SECRET_NAME="openbao-init-keys"
SECRET_FILE="/tmp/openbao-keys.json"
MAX_RETRIES=30
SLEEP_SECONDS=5

log() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
    exit 1
}

wait_for_openbao() {
  log "Waiting for OpenBao to become available..."
  local i=0
  until kubectl exec \${POD_NAME} -n \${POD_NAMESPACE} -c openbao -- date; do
    ((i++))
    if [ "$i" -ge "$MAX_RETRIES" ]; then
      error "OpenBao is not responding after $((MAX_RETRIES * SLEEP_SECONDS)) seconds."
    fi
    sleep "$SLEEP_SECONDS"
  done
  log "OpenBao is reachable."
}

wait_for_openbao

set +e
is_initialized=$(kubectl exec \${POD_NAME} -n \${POD_NAMESPACE} -c openbao -- bao status -format=json | jq -r '.initialized')
set -e

echo $is_initialized

if [ "$is_initialized" == "false" ]; then
    log "OpenBao is not initialized. Initializing..."

    kubectl exec \${POD_NAME} -n \${POD_NAMESPACE} -c openbao -- bao operator init -format=json > "$SECRET_FILE"

    unseal_keys=$(jq -r '.unseal_keys_b64[]' "$SECRET_FILE")
    root_token=$(jq -r '.root_token' "$SECRET_FILE")

    log "Saving unseal keys and root token to Kubernetes secret: $OPENBAO_SECRET_NAME"

    kubectl create secret generic "$OPENBAO_SECRET_NAME" \
    --namespace="\${POD_NAMESPACE}" \
    --from-literal=keys="$(jq -c '.unseal_keys_b64' "$SECRET_FILE")" \
    --from-literal=root_token="$root_token" \
    --dry-run=client -o yaml | kubectl apply -f -
else
    log "OpenBao is already initialized."
fi

set +e
is_sealed=$(kubectl exec \${POD_NAME} -n \${POD_NAMESPACE} -c openbao -- bao status -format=json | jq -r '.sealed')
set -e

if [ "$is_sealed" == "true" ]; then
    log "OpenBao is sealed. Attempting to unseal..."

    keys_json=$(kubectl get secret "$OPENBAO_SECRET_NAME" \
    -n "\${POD_NAMESPACE}" -o jsonpath='{.data.keys}' | base64 -d)

    for key in $(echo "$keys_json" | jq -r '.[]'); do
    kubectl exec \${POD_NAME} -n \${POD_NAMESPACE} -c openbao -- bao operator unseal "$key"
    if [ "$(kubectl exec \${POD_NAME} -n \${POD_NAMESPACE} -c openbao -- bao status -format=json | jq -r '.sealed')" == "false" ]; then
        log "OpenBao successfully unsealed."
        break
    fi
    done
else
    log "OpenBao is already unsealed."
fi

exit 0
"""
        }
        _name = "${_name}-script-cm"
        _projectNamespace = _projectNamespace
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://openbao.github.io/openbao-helm"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "openbao"
        _helmChartVersion = "0.10.1"
        _helmReleaseName = "openbao"
        _helmReleaseNamespace = "openbao"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            server = {
                annotations = {
                    "checksum/init-and-unseal.sh" = crypto.sha256(k8sScriptsConfigMap.managedResource.spec.forProvider.manifest.data["init-and-unseal.sh"])
                }
                extraContainers = [
                    {
                        name = "vault-init-and-unseal"
                        image = "bitnami/kubectl:latest"
                        command = ["/bin/sh", "-c"]
                        args = [
                            """\
#!/bin/bash

/scripts/init-and-unseal.sh

# keep the container running forever
tail -f /dev/null
"""
                        ]
                        env = [
                            {
                                name = "POD_NAMESPACE"
                                valueFrom.fieldRef.fieldPath = "metadata.namespace"
                            }
                            {
                                name = "POD_NAME"
                                valueFrom.fieldRef.fieldPath = "metadata.name"
                            }
                            {
                                name = "OPENBAO_SECRET_NAME"
                                value = "${_name}-keys-and-root-token"
                            }
                        ]
                        volumeMounts = [
                            {
                                name = "scripts"
                                mountPath = "/scripts"
                            }
                        ]
                    }
                ]
                volumes = [
                    {
                        name = "scripts"
                        configMap = {
                            name = k8sScriptsConfigMap.managedResource.spec.forProvider.manifest.metadata.name
                            defaultMode = int(0o755)
                        }
                    }
                ]
                ingress = {
                    enabled = True
                    annotaions = {
                        "cert-manager.io/cluster-issuer" = "letsencrypt"
                    }
                    ingressClassName = "nginx"
                    hosts = [
                        {
                            host = _domain
                            paths = []
                        }
                    ]
                    tls = [
                        {
                            secretName = "${_domain}-tls"
                            hosts = [_domain]
                        }
                    ]
                }
                serviceAccount = {
                    create = False
                    name = k8sServiceAccount.managedResource.spec.forProvider.manifest.metadata.name
                }
            }
        }
        _uses = [
            kcOpenBaoAdminsGroup.managedResource
            k8sRoleBinding.managedResource
            k8sScriptsConfigMap.managedResource
        ]
    }
    providerConfigKcClient: core.KcOpenIdClientOpenBaoXpProviderWrapper {
        _instanceName = _instanceName
        _instanceOwnerProjectName = _projectNamespace
        _projectName = "root"
        _projectNamespace = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            helmRelease.managedResource
        ]
    }
    providerConfigKcClientDefaultScopes: core.KcOpenIdClientDefaultScopesWrapper {
        _additionalScopes = ["groups"]
        _clientId = providerConfigKcClient.getAtProviderId(_observedComposedResources)
        _instanceName = _kcInstanceName
        _instanceOwnerProjectName = _projectNamespace
        _name = "${providerConfigKcClient.managedResource.spec.forProvider.name}-client-default-scopes"
        _projectName = _projectNamespace
        _realmId = _kcRealmId
        _uses = [
            providerConfigKcClient.managedResource
        ]
    }
    kcUserGroupsWrapper: core.KcUserGroupsWrapper {
        _keycloakGroupIds = [kcOpenBaoAdminsGroup.getAtProviderId(_observedComposedResources)]
        _keycloakInstanceName = _instanceName
        _keycloakInstanceOwnerProjectName = _projectNamespace
        _keycloakRealmId = _kcRealmId
        _keycloakUserId = providerConfigKcClient.getServiceAccountUserId(_observedComposedResources)
        _projectName = _projectNamespace
        _uses = [
            kcOpenBaoAdminsGroup.managedResource
        ]
    }
    k8sKeysRootTokenSecretObserve: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = "${_name}-keys-and-root-token"
        _namespace = "openbao"
        _projectName = _projectNamespace
        _secretName = "${_name}-keys-and-root-token"
        _stringData = {}
        _uses = [
            helmRelease.managedResource
        ]
        managedResource.spec.managementPolicies = ["Observe"]
    }
    providerConfigCredentialsSecret: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = openBaoUtils.openBaoProviderConfigSecretName(_projectNamespace, _instanceName, _projectNamespace, "admin")
        _namespace = _projectNamespace
        _projectName = _projectNamespace
        _secretName = openBaoUtils.openBaoProviderConfigSecretName(_projectNamespace, _instanceName, _projectNamespace, "admin")
        _stringData = {
            value = json.encode({
                token = k8sKeysRootTokenSecretObserve.getData(_observedComposedResources, "root_token")
            })
        }
        _uses = [
            k8sKeysRootTokenSecretObserve.managedResource
        ]
    }
    providerConfig: core.OpenBaoProviderConfigWrapper {
        _credentialsSecretName = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.name
        _credentialsSecretNamespace = providerConfigCredentialsSecret.managedResource.spec.forProvider.manifest.metadata.namespace
        _openBaoDomain = _domain
        _openBaoInstanceContext = "admin"
        _openBaoInstanceName = _instanceName
        _openBaoInstanceOwnerProjectName = _projectNamespace
        _projectName = _projectNamespace
        _uses = [
            providerConfigCredentialsSecret.managedResource
        ]
    }

    managedResources: [core.ManagedResource | core.OpenBaoProviderConfig] = [
        kcOpenBaoClient.managedResource
        kcOpenBaoClientDefaultScopes.managedResource
        kcOpenBaoAdminsGroup.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        providerConfigKcClient.managedResource
        providerConfigKcClientDefaultScopes.managedResource
        kcUserGroupsWrapper.managedResource
        k8sKeysRootTokenSecretObserve.managedResource
        providerConfigCredentialsSecret.managedResource
        providerConfig.managedResource
        k8sServiceAccount.managedResource
        k8sRole.managedResource
        k8sRoleBinding.managedResource
        k8sScriptsConfigMap.managedResource
    ]
    usages: [core.Usage] = sum([
        kcOpenBaoClient.usages
        kcOpenBaoClientDefaultScopes.usages
        kcOpenBaoAdminsGroup.usages
        helmRepo.usages
        helmRelease.usages
        providerConfigKcClient.usages
        providerConfigKcClientDefaultScopes.usages
        kcUserGroupsWrapper.usages
        k8sKeysRootTokenSecretObserve.usages
        providerConfigCredentialsSecret.usages
        providerConfig.usages
        k8sServiceAccount.usages
        k8sRole.usages
        k8sRoleBinding.usages
        k8sScriptsConfigMap.usages
    ], [])

