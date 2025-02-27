import crypto

kcProviderConfigName: (str, str, str, str) -> str = lambda projectName: str, kcInstanceName: str, kcInstanceOwnerProjectName: str, kcRealmId: str -> str {
    _humanReadablePrefix = "${projectName}-kc-${kcInstanceName}-${kcInstanceOwnerProjectName}"
    _humanReadableName = "${_humanReadablePrefix}-${kcRealmId}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}-${kcRealmId}"

    _name = _hashedName
}
