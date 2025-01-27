import core.v1alpha1 as core

schema K8sAppPlatformSnapshotController:
    _name: str
    _kustomizationDependencies?: [core.K8sFluxKustomizationWrapper] = []
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    gitRepo: core.K8sFluxGitRepositoryWrapper {
        _name = "${_name}-repo"
        _gitUrl = "https://github.com/kubernetes-csi/external-snapshotter"
        _gitTag = "v8.1.0"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    crdKustomization: core.K8sFluxKustomizationWrapper {
        _name = "${_name}-crd-kust"
        _path = "./client/config/crd"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    csiSnapshotterKustomization: core.K8sFluxKustomizationWrapper {
        _name = "${_name}-csi-snap-kust"
        _path = "./deploy/kubernetes/csi-snapshotter"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [crdKustomization] + _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    snapshotControllerKustomization: core.K8sFluxKustomizationWrapper {
        _name = "${_name}-snap-ctl-kust"
        _path = "./deploy/kubernetes/snapshot-controller"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [csiSnapshotterKustomization] + _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    managedResources: [core.ManagedResource] = [
        gitRepo.managedResource
        crdKustomization.managedResource
        csiSnapshotterKustomization.managedResource
        snapshotControllerKustomization.managedResource
    ]

    usages: [core.Usage] = gitRepo.usages + crdKustomization.usages + csiSnapshotterKustomization.usages + snapshotControllerKustomization.usages

