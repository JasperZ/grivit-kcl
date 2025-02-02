import manifests

manifests.yaml_stream([
    k8sAppOperationsKeycloakXr
    k8sAppOperationsKeycloakXrd
    k8sClusterOsStandaloneXr
    k8sClusterOsStandaloneXrd
    k8sClusterOsK0smotronXr
    k8sClusterOsK0smotronXrd
    kcStageXr
    kcStageXrd
    osStageXr
    osStageXrd
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
