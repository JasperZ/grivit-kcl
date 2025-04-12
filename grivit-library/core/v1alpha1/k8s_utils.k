import crypto

k8sProviderConfigName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = crypto.md5("${projectName}-${clusterName}") + "-k8s"
}

k8sProviderConfigSecretName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = k8sProviderConfigName(projectName, clusterName) + "-provider"
}
