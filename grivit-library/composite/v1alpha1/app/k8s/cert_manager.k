import core.v1alpha1 as core

schema CertManagerAppK8s:
    _clusterName: str
    _email: str
    _fluxHelmReleaseDependencies?: [core.K8sFluxHelmReleaseWrapper]
    _name: str
    _observedComposedResources: any
    _projectNamespace: str

    awsUser: core.AwsIamUserWrapper {
        _name = "${_name}-aws-user"
        _projectNamespace = _projectNamespace
    }
    awsAccessKey: core.AwsIamAccessKeyWrapper {
        _name = "${_name}-aws-access-key"
        _awsIamUserName = awsUser.managedResource.metadata.name
        _projectNamespace = _projectNamespace
    }
    awsPolicy: core.AwsIamPolicyWrapper {
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
        _projectNamespace = _projectNamespace
    }
    awsUserPolicyAttachment: core.AwsIamUserPolicyAttachmentWrapper {
        _name = "${_name}-aws-user-policy-attachment"
        _userName = awsUser.managedResource.metadata.name
        _policyArn = awsPolicy.getPolicyArn(_observedComposedResources)
        _projectNamespace = _projectNamespace
    }
    helmRepo: core.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://charts.jetstack.io"
        _projectNamespace = _projectNamespace
    }
    helmRelease: core.K8sFluxHelmReleaseWrapper {
        _clusterName = _clusterName
        _name = "${_name}-rel"
        _helmChartName = "cert-manager"
        _helmChartVersion = "1.15.3"
        _helmReleaseName = "cert-manager"
        _helmReleaseNamespace = "cert-manager"
        _helmRepositoryWrapper = helmRepo
        _helmReleaseWrapperDependencies = _fluxHelmReleaseDependencies
        _projectNamespace = _projectNamespace
        managedResource.spec.forProvider.manifest.spec.values = {
            cainjector = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "128Mi"
                    requests.cpu = "50m"
                    requests.memory = "128Mi"
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
                limits.cpu = "50m"
                limits.memory = "64Mi"
                requests.cpu = "50m"
                requests.memory = "64Mi"
            }
            startupapicheck = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
            webhook = {
                resources = {
                    limits.cpu = "50m"
                    limits.memory = "64Mi"
                    requests.cpu = "50m"
                    requests.memory = "64Mi"
                }
            }
        }
    }
    clusterIssuerCredentials: core.K8sObjectSecretWrapper {
        _clusterName = _clusterName
        _name = "${_name}-cluster-issuer-credentials"
        _namespace = "cert-manager"
        _projectName = _projectNamespace
        _secretName = "${_name}-cluster-issuer-credentials"
        _stringData = {
            accessKeyId = awsAccessKey.getAccessKeyId(_observedComposedResources)
            accessKeySecret = awsAccessKey.getAccessKeySecret(_observedComposedResources)
        }
    }
    clusterIssuer: core.K8sObjectGenericWrapper {
        _clusterName = _clusterName
        _name = "${_name}-cluster-issuer"
        _projectNamespace = _projectNamespace
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

