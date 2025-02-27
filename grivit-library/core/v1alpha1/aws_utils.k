import crypto

awsProviderConfigName: (str) -> str = lambda projectName: str -> str {
    _humanReadablePrefix = "${projectName}-aws"
    _humanReadableName = "${_humanReadablePrefix}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}"

    _name = _hashedName
}

awsProviderConfigSecretName: (str) -> str = lambda projectName: str -> str {
    _providerConfigName = awsProviderConfigName(projectName)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
