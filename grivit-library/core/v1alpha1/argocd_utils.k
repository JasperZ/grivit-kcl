import crypto

argoCdProviderConfigName: (str, str, str, str) -> str = lambda projectName: str, argoCdInstanceName: str, argoCdInstanceOwnerProjectName: str, argoCdProjectName: str -> str {
    _humanReadablePrefix = "${projectName}-argocd-${argoCdInstanceName}-${argoCdInstanceOwnerProjectName}"
    _humanReadableName = "${_humanReadablePrefix}-${argoCdProjectName}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${argoCdProjectName}"

    _name = _hashedName
}

argoCdProviderConfigSecretName: (str, str, str, str) -> str = lambda projectName: str, argoCdInstanceName: str, argoCdInstanceOwnerProjectName: str, argoCdProjectName: str -> str {
    _providerConfigName = argoCdProviderConfigName(projectName, argoCdInstanceName, argoCdInstanceOwnerProjectName, argoCdProjectName)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
