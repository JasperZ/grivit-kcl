import core.v1alpha1 as core

schema K8sAppPlatformSnapshotController:
    _clusterName: str
    _name: str
    _kustomizationDependencies?: [core.K8sFluxKustomizationWrapper] = []
    _projectNamespace: str

    gitRepo: core.K8sFluxGitRepositoryWrapper {
        _gitTag = "v8.1.0"
        _gitUrl = "https://github.com/kubernetes-csi/external-snapshotter"
        _name = "${_name}-repo"
        _projectNamespace = _projectNamespace
    }
    crdKustomization: core.K8sFluxKustomizationWrapper {
        _clusterName = _clusterName
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = _kustomizationDependencies
        _name = "${_name}-crd-kust"
        _path = "./client/config/crd"
        _projectNamespace = _projectNamespace
        _targetNamespace = "kube-system"
    }
    csiSnapshotterKustomization: core.K8sFluxKustomizationWrapper {
        _clusterName = _clusterName
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [crdKustomization] + _kustomizationDependencies
        _name = "${_name}-csi-snap-kust"
        _path = "./deploy/kubernetes/csi-snapshotter"
        _projectNamespace = _projectNamespace
        _targetNamespace = "kube-system"
    }
    snapshotControllerKustomization: core.K8sFluxKustomizationWrapper {
        _clusterName = _clusterName
        _k8sFluxGitRepository = gitRepo
        _kustomizationDependencies = [csiSnapshotterKustomization] + _kustomizationDependencies
        _name = "${_name}-snap-ctl-kust"
        _path = "./deploy/kubernetes/snapshot-controller"
        _projectNamespace = _projectNamespace
        _targetNamespace = "kube-system"
    }
    managedResources: [core.ManagedResource] = [
        gitRepo.managedResource
        crdKustomization.managedResource
        csiSnapshotterKustomization.managedResource
        snapshotControllerKustomization.managedResource
    ]

    usages: [core.Usage] = gitRepo.usages + crdKustomization.usages + csiSnapshotterKustomization.usages + snapshotControllerKustomization.usages

