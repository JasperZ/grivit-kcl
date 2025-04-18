import crypto

helmProviderConfigName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = crypto.md5(projectName)[:8] + "-helm-" + clusterName
}

helmProviderConfigSecretName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _name = helmProviderConfigName(projectName, clusterName) + "-provider"
}
