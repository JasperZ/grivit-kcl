import xresources.v1alpha1 as res

schema K8sAppPlatformSnapshotController:
    _name: str
    _kustomizationDependencies?: [res.K8sFluxKustomizationWrapper] = []
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _tenantNamespace: str

    gitRepo: res.K8sFluxGitRepositoryWrapper {
        _name = "${_name}-repo"
        _gitUrl = "https://github.com/kubernetes-csi/external-snapshotter"
        _gitTag = "v8.1.0"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    crdKustomization: res.K8sFluxKustomizationWrapper {
        _name = "${_name}-crd-kust"
        _path = "./client/config/crd"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    csiSnapshotterKustomization: res.K8sFluxKustomizationWrapper {
        _name = "${_name}-csi-snap-kust"
        _path = "./deploy/kubernetes/csi-snapshotter"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [crdKustomization] + _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    snapshotControllerKustomization: res.K8sFluxKustomizationWrapper {
        _name = "${_name}-snap-ctl-kust"
        _path = "./deploy/kubernetes/snapshot-controller"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [csiSnapshotterKustomization] + _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    managedResources: [res.ManagedResource] = [
        gitRepo.managedResource
        crdKustomization.managedResource
        csiSnapshotterKustomization.managedResource
        snapshotControllerKustomization.managedResource
    ]

    usages: [res.Usage] = gitRepo.usages + crdKustomization.usages + csiSnapshotterKustomization.usages + snapshotControllerKustomization.usages

