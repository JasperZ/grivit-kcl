import crypto

openBaoProviderConfigName: (str, str, str, str) -> str = lambda projectName: str, openBaoInstanceName: str, openBaoInstanceOwnerProjectName: str, openBaoProjectName: str -> str {
    _humanReadablePrefix = "${projectName}-openbao-${openBaoInstanceName}-${openBaoInstanceOwnerProjectName}"
    _humanReadableName = "${_humanReadablePrefix}-${openBaoProjectName}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${openBaoProjectName}"

    _name = _hashedName
}

openBaoProviderConfigSecretName: (str, str, str, str) -> str = lambda projectName: str, openBaoInstanceName: str, openBaoInstanceOwnerProjectName: str, openBaoProjectName: str -> str {
    _providerConfigName = openBaoProviderConfigName(projectName, openBaoInstanceName, openBaoInstanceOwnerProjectName, openBaoProjectName)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
