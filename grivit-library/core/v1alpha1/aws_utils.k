import crypto

awsProviderConfigName: (str) -> str = lambda projectName: str -> str {
    _name = crypto.md5(projectName)[:8] + "-aws"
}

awsProviderConfigSecretName: (str) -> str = lambda projectName: str -> str {
    _name = awsProviderConfigName(projectName) + "-provider"
}
