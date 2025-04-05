import crypto

schema ArgoCdInstance:
    domain: str
    name: str
    ownerProjectName: str
    projectName: str

argoCdProviderConfigName: (str, ArgoCdInstance) -> str = lambda projectName: str, argoCdInstance: ArgoCdInstance -> str {
    _humanReadablePrefix = "${projectName}-argocd-${argoCdInstance.name}-${argoCdInstance.ownerProjectName}"
    _humanReadableName = "${_humanReadablePrefix}-${argoCdInstance.projectName}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${argoCdInstance.projectName}"

    _name = _hashedName
}

argoCdProviderConfigSecretName: (str, ArgoCdInstance) -> str = lambda projectName: str, argoCdInstance: ArgoCdInstance -> str {
    _providerConfigName = argoCdProviderConfigName(projectName, argoCdInstance)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
