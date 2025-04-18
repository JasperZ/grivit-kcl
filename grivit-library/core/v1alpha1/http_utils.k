import crypto

httpProviderConfigName: (str) -> str = lambda projectName: str -> str {
    _name = crypto.md5(projectName)[:8] + "-http"
}
