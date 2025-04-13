import crypto

helmProviderConfigName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = crypto.md5(projectName) + "-helm-" + clusterName
}

helmProviderConfigSecretName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = helmProviderConfigName(projectName, clusterName) + "-provider"
}
