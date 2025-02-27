import crypto

k8sProviderConfigName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _humanReadablePrefix = "${projectName}-k8s"
    _humanReadableName = "${_humanReadablePrefix}-${clusterName}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${clusterName}"

    _name = _hashedName
}

k8sProviderConfigSecretName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _providerConfigName = k8sProviderConfigName(projectName, clusterName)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
