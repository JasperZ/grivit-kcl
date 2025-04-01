import crypto

httpProviderConfigName: (str) -> str = lambda projectName: str -> str {
    _humanReadablePrefix = "${projectName}-http"
    _humanReadableName = "${_humanReadablePrefix}"

    _hashedPrefix = crypto.md5(_humanReadablePrefix)
    _hashedName = "${_hashedPrefix}"

    _name = _hashedName
}
