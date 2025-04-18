import crypto

osProviderConfigName: (str) -> str = lambda projectName: str -> str {
    _name = crypto.md5(projectName)[:8] + "-os"
}

osProviderConfigSecretName: (str) -> str = lambda projectName: str -> str {
    _name = osProviderConfigName(projectName) + "-provider"
}
