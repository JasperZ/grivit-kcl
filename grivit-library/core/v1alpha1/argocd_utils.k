import crypto

schema ArgoCdInstance:
    domain: str
    name: str
    ownerProjectName: str
    projectName: str

argoCdProviderConfigName: (str, ArgoCdInstance) -> str = lambda projectName: str, argoCdInstance: ArgoCdInstance -> str {
    _name = crypto.md5("${projectName}-${argoCdInstance.ownerProjectName}-${argoCdInstance.name}")[:8] + "-argocd-${argoCdInstance.projectName}"
}

argoCdProviderConfigSecretName: (str, ArgoCdInstance) -> str = lambda projectName: str, argoCdInstance: ArgoCdInstance -> str {
    _name = argoCdProviderConfigName(projectName, argoCdInstance) + "-provider"
}

argoCdControlPlaneProjectName: (ArgoCdInstance) -> str = lambda argoCdInstance: ArgoCdInstance -> str {
    _name = crypto.md5("${argoCdInstance.ownerProjectName}-${argoCdInstance.name}")[:8] + "-${argoCdInstance.projectName}-controlplane"
}

argoCdTenantProjectName: (ArgoCdInstance) -> str = lambda argoCdInstance: ArgoCdInstance -> str {
    _name = crypto.md5("${argoCdInstance.ownerProjectName}-${argoCdInstance.name}")[:8] + "-${argoCdInstance.projectName}-tenant"
}

argoCdClusterName: (str, ArgoCdInstance) -> str = lambda clusterName: str, argoCdInstance: ArgoCdInstance -> str {
    _name = "${argoCdInstance.projectName}-${clusterName}"
}
