import core.v1alpha1 as core

schema K8sAppPlatformCertManager:
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _email: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _targetK8sProviderConfig: core.K8sProviderConfigWrapper
    _tenantNamespace: str

    awsUser: core.AwsIamUserWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-user"
    }
    awsAccessKey: core.AwsIamAccessKeyWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-access-key"
        _awsIamUserName = awsUser.managedResource.metadata.name
        _tenantNamespace = _tenantNamespace
    }
    awsPolicy: core.AwsIamPolicyWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-policy"
        _description = "Allow ${_name} to access Route53"
        _policy = """\
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": "route53:GetChange",
        "Resource": "arn:aws:route53:::change/*"
        },
        {
        "Effect": "Allow",
        "Action": [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
        "Effect": "Allow",
        "Action": "route53:ListHostedZonesByName",
        "Resource": "*"
        }
    ]
}
"""
    }
    awsUserPolicyAttachment: core.AwsIamUserPolicyAttachmentWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-user-policy-attachment"
        _userName = awsUser.managedResource.metadata.name
        _policyArn = awsPolicy.getPolicyArn(_observedComposedResources)
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://charts.jetstack.io"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _name = "${_name}-rel"
        _helmChartName = "cert-manager"
        _helmChartVersion = "1.15.3"
        _helmReleaseName = "cert-manager"
        _helmReleaseNamespace = "cert-manager"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _targetK8sProviderConfig = _targetK8sProviderConfig
        _tenantNamespace = _tenantNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            cainjector = {
                resources = {
                    limit.cpu = "50m"
                    limit.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
            crds = {
                enabled = True
            }
            extraArgs = [
                "--dns01-recursive-nameservers-only"
                "--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53"
            ]
            resources = {
                limit.cpu = "50m"
                    limit.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
            }
            startupapicheck = {
                resources = {
                    limit.cpu = "50m"
                    limit.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
            webhook = {
                resources = {
                    limit.cpu = "50m"
                    limit.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
        }
    }
    clusterIssuerCredentials: core.K8sObjectSecretWrapper {
        _name = "${_name}-cluster-issuer-credentials"
        _targetK8sProviderConfigName = _targetK8sProviderConfig.managedResource.metadata.name
        _stringData = {
            accessKeyId = awsAccessKey.getAccessKeyId(_observedComposedResources)
            accessKeySecret = awsAccessKey.getAccessKeySecret(_observedComposedResources)
        }
        _targetNamespace = "cert-manager"
    }
    clusterIssuer: core.K8sObjectGenericWrapper {
        _name = "${_name}-cluster-issuer"
        _targetK8sProviderConfigName = _targetK8sProviderConfig.managedResource.metadata.name
        managedResource.spec.forProvider.manifest = {
            apiVersion = "cert-manager.io/v1"
            kind = "ClusterIssuer"
            metadata.name = "letsencrypt"
            spec.acme = {
                server = "https://acme-v02.api.letsencrypt.org/directory"
                # ToDo: hard coded email
                email = _email
                privateKeySecretRef = {
                    name = "letsencrypt-cluster-issuer-private-key"
                }
                solvers = [
                    {
                        dns01.route53 = {
                            region = "us-east-1"
                            accessKeyIDSecretRef = {
                                name = clusterIssuerCredentials.managedResource.metadata.name
                                key = "accessKeyId"
                            }
                            secretAccessKeySecretRef = {
                                name = clusterIssuerCredentials.managedResource.metadata.name
                                key = "accessKeySecret"
                            }
                        }
                    }
                ]
            }
        }
    }
    managedResources: [core.ManagedResource] = [
        awsUser.managedResource
        awsAccessKey.managedResource
        awsPolicy.managedResource
        awsUserPolicyAttachment.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        clusterIssuerCredentials.managedResource
        clusterIssuer.managedResource
    ]

    usages: [core.Usage] = awsUser.usages + awsAccessKey.usages + awsPolicy.usages + awsUserPolicyAttachment.usages + helmRepo.usages + helmRelease.usages + clusterIssuerCredentials.usages + clusterIssuer.usages

