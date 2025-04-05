import crypto

schema KeycloakInstance:
    domain: str
    name: str
    ownerProjectName: str
    realmId: str

kcProviderConfigName: (str, KeycloakInstance) -> str = lambda projectName: str, keycloakInstance: KeycloakInstance -> str {
    _humanReadablePrefix = "${projectName}-kc-${keycloakInstance.name}-${keycloakInstance.ownerProjectName}"
    _humanReadableName = "${_humanReadablePrefix}-${keycloakInstance.realmId}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${keycloakInstance.realmId}"

    _name = _hashedName
}

kcProviderConfigSecretName: (str, KeycloakInstance) -> str = lambda projectName: str, keycloakInstance: KeycloakInstance -> str {
    _providerConfigName = kcProviderConfigName(projectName, keycloakInstance)
    _providerConfigSecretName = "${_providerConfigName}-provider"

    _name = _providerConfigSecretName
}
