import regex
import core.v1alpha1 as core

schema PublicRegistryCachesHarborAppK8s:
    _claimName: str
    _claimNamespace: str
    _observedComposedResources: any

    _publicRegistryConfigurations: any = {
        "docker.io" = {
            registryEndpointUrl = "https://registry-1.docker.io"
            registryProviderName = "docker-registry"
        }
        "quay.io" = {
            registryEndpointUrl = "https://quay.io"
            registryProviderName = "docker-registry"
        }
        "registry.k8s.io" = {
            registryEndpointUrl = "https://registry.k8s.io"
            registryProviderName = "docker-registry"
        }
        "ghcr.io" = {
            registryEndpointUrl = "https://ghcr.io"
            registryProviderName = "docker-registry"
        }
    }

    _resourceNamePrefix: str = _claimName + "-harbor-"
    _resourceNameSuffix: str = ""

    _registries: {str:core.HarborRegistry} = {configName = core.HarborRegistry {
        _harborRegistryDescription = config.registryEndpointUrl + " registry managed by Crossplane"
        _harborRegistryEndpointUrl = config.registryEndpointUrl
        _harborRegistryName = configName
        _harborRegistryProviderName = config.registryProviderName
        _resourceName = _resourceNamePrefix + "registry-" + regex.replace(configName, "\.", "-") + _resourceNameSuffix
    } for configName, config in _publicRegistryConfigurations}

    _projects: {str:core.HarborProject} = {configName = core.HarborProject {
        _harborProjectName = "cache-" + configName
        _harborProjectPublic = True
        _harborProjectRegistryId = _registries[configName].getProviderAtRegistryId(_observedComposedResources)
        _resourceName = _resourceNamePrefix + "project-" + regex.replace(configName, "\.", "-") + _resourceNameSuffix
    } for configName, config in _publicRegistryConfigurations}

    managedResources: [core.ManagedResource] = [registry.managedResource for registryName, registry in _registries] + [project.managedResource for projectName, project in _projects]
    usages: [core.Usage] = sum([registry.usages for registryName, registry in _registries], []) + sum([project.usages for projectName, project in _projects], [])

