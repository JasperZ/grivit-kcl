import crypto

helmProviderConfigName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _humanReadablePrefix = "${projectName}-helm"
    _humanReadableName = "${_humanReadablePrefix}-${clusterName}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${clusterName}"

    _name = _hashedName
}

helmProviderConfigSecretName: (str, str) -> str = lambda projectName: str, clusterName: str -> str {
    _providerConfigName = helmProviderConfigName(projectName, clusterName)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
