# Generate Crossplane Resources
```sh
mkdir ./out

# Projects
kcl run ./v1alpha1/cloud/grivit/project/configuration/controlplane > ./out/cloud_grivit_project_configuration_controlplane.yaml
kubectl apply -f ./out/cloud_grivit_project_configuration_controlplane.yaml

kcl run ./v1alpha1/cloud/grivit/project/configuration/tenant > ./out/cloud_grivit_project_configuration_tenant.yaml
kubectl apply -f ./out/cloud_grivit_project_configuration_tenant.yaml

# Apps
kcl run ./v1alpha1/cloud/grivit/app/k8s/argocd > ./out/cloud_grivit_app_k8s_argocd.yaml
kubectl apply -f ./out/cloud_grivit_app_k8s_argocd.yaml

kcl run ./v1alpha1/cloud/grivit/app/k8s/keycloak > ./out/cloud_grivit_app_k8s_keycloak.yaml
kubectl apply -f ./out/cloud_grivit_app_k8s_keycloak.yaml

# Project Integrations
kcl run ./v1alpha1/cloud/grivit/project/integration/argocd > ./out/cloud_grivit_project_integration_argocd.yaml
kubectl apply -f ./out/cloud_grivit_project_integration_argocd.yaml

kcl run ./v1alpha1/cloud/grivit/project/integration/keycloak > ./out/cloud_grivit_project_integration_keycloak.yaml
kubectl apply -f ./out/cloud_grivit_project_integration_keycloak.yaml

# K8s Clusters
kcl run ./v1alpha1/cloud/grivit/cluster/k8s/infra/os/capi_standalone > ./out/cloud_grivit_cluster_k8s_insfra_os_capi_standalone.yaml
kubectl apply -f ./out/cloud_grivit_cluster_k8s_insfra_os_capi_standalone.yaml

# K8s Cluster Integrations
kcl run ./v1alpha1/cloud/grivit/cluster/k8s/integ/argocd > ./out/cloud_grivit_cluster_k8s_integ_argocd.yaml
kubectl apply -f ./out/cloud_grivit_cluster_k8s_integ_argocd.yaml
```

# Apply Crossplane Manifests
```sh
kubectl apply -R -f ./out
```
