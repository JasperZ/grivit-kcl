import crypto

schema K8sCluster:
    name: str
    projectName: str

k8sProviderConfigName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = crypto.md5(projectName) + "-k8s-" + clusterName
}

k8sProviderConfigSecretName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = k8sProviderConfigName(projectName, clusterName) + "-provider"
}
