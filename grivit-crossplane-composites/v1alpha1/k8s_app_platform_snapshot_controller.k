import api.cp.core.v1 as cpCore
import api.cp.k8s.core.v1 as cpK8sCore
import api.cp.k8s.flux.v1 as cpK8sFlux

schema K8sAppPlatformSnapshotController:
    _name: str
    _kustomizationDependencies?: [cpK8sFlux.KustomizationWrapper] = []
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: cpK8sCore.ProviderConfigWrapper
    _tenantNamespace: str

    gitRepo: cpK8sFlux.GitRepositoryWrapper {
        _name = "${_name}-repo"
        _gitUrl = "https://github.com/kubernetes-csi/external-snapshotter"
        _gitTag = "v8.1.0"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    crdKustomization: cpK8sFlux.KustomizationWrapper {
        _name = "${_name}-crd-kust"
        _path = "./client/config/crd"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    csiSnapshotterKustomization: cpK8sFlux.KustomizationWrapper {
        _name = "${_name}-csi-snap-kust"
        _path = "./deploy/kubernetes/csi-snapshotter"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [crdKustomization] + _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    snapshotControllerKustomization: cpK8sFlux.KustomizationWrapper {
        _name = "${_name}-snap-ctl-kust"
        _path = "./deploy/kubernetes/snapshot-controller"
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [csiSnapshotterKustomization] + _kustomizationDependencies
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _targetNamespace = "kube-system"
        _tenantNamespace = _tenantNamespace
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
    }
    managedResources: [cpCore.ManagedResource] = [
        gitRepo.managedResource
        crdKustomization.managedResource
        csiSnapshotterKustomization.managedResource
        snapshotControllerKustomization.managedResource
    ]

    usages: [cpCore.Usage] = gitRepo.usages + crdKustomization.usages + csiSnapshotterKustomization.usages + snapshotControllerKustomization.usages

