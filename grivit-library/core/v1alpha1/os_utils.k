import crypto

osProviderConfigName: (str) -> str = lambda projectName: str -> str {
    _humanReadablePrefix = "${projectName}-os"
    _humanReadableName = "${_humanReadablePrefix}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}"

    _name = _hashedName
}

osProviderConfigSecretName: (str) -> str = lambda projectName: str -> str {
    _providerConfigName = osProviderConfigName(projectName)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
