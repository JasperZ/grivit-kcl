import manifests

manifests.yaml_stream([
    k8sClusterOsStandaloneXr
    k8sClusterOsStandaloneXrd
    osStageXr
    osStageXrd
], {
    sort_keys = False
    ignore_private = True
    ignore_none = False
    sep = "---"
})
