# Generate Crossplane Resources
```sh
mkdir ./out

kcl run composite-resource/v1alpha1/k8s/app/operations/argocd > ./out/k8s_app_operations_argocd.yaml
kcl run composite-resource/v1alpha1/k8s/app/operations/keycloak > ./out/k8s_app_operations_keycloak.yaml
kcl run composite-resource/v1alpha1/k8s/cluster/os/k0smotron > ./out/k8s_cluster_os_k0smotron.yaml
kcl run composite-resource/v1alpha1/k8s/cluster/os/standalone > ./out/k8s_cluster_os_standalone.yaml
kcl run composite-resource/v1alpha1/kc/stage > ./out/kc_stage.yaml
kcl run composite-resource/v1alpha1/os/stage > ./out/os_stage.yaml
```

# Apply Crossplane Manifests
```sh
kubectl apply -R -f out
```