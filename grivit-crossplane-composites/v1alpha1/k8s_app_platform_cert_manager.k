import xresources.v1alpha1 as res
import base64

schema K8sAppPlatformCertManager:
    _name: str
    _fluxHelmReleaseDependencies?: [res.K8sFluxHelmReleaseWrapper]
    _controlPlaneAwsProviderConfigName: str
    _controlPlaneK8sProviderConfigName: str
    _targetK8sProviderConfig: res.K8sProviderConfigWrapper
    _tenantNamespace: str
    _observedCompositeResource: any

    awsUser: res.AwsIamUserWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-user"
    }
    awsAccessKey: res.AwsIamAccessKeyWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-access-key"
        _awsIamUserWrapper = awsUser
        _tenantNamespace = _tenantNamespace
    }
    awsPolicy: res.AwsIamPolicyWrapper {
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
    _awsPolicyArn: str = ""
    _awsPolicyName: str = awsPolicy.managedResource.metadata.name
    if _awsPolicyName in _observedCompositeResource:
        _awsPolicyArn = str(_observedCompositeResource[_awsPolicyName].Resource?.status?.atProvider?.arn or "")

    awsUserPolicyAttachment: res.AwsIamUserPolicyAttachmentWrapper {
        _controlPlaneAwsProviderConfigName = _controlPlaneAwsProviderConfigName
        _name = "${_name}-aws-user-policy-attachment"
        _userName = awsUser.managedResource.metadata.name
        _policyArn = _awsPolicyArn
    }
    helmRepo: res.K8sFluxHelmRepositoryWrapper {
        _name = "${_name}-repo"
        _helmRepoUrl = "https://charts.jetstack.io"
        _controlPlaneK8sProviderConfigName = _controlPlaneK8sProviderConfigName
        _tenantNamespace = _tenantNamespace
    }
    helmRelease: res.K8sFluxHelmReleaseWrapper {
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
            crds = {
                enabled = True
            }
            extraArgs = [
                "--dns01-recursive-nameservers-only"
                "--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53"
            ]
        }
    }
    _accessKeyId: str = ""
    _accessKeySecret: str = ""
    _accessKeyName: str = awsAccessKey.managedResource.metadata.name
    if _accessKeyName in _observedCompositeResource:
        _accessKeyId = str(base64.decode(_observedCompositeResource[_accessKeyName].ConnectionDetails?.username))
        _accessKeySecret = str(base64.decode(_observedCompositeResource[_accessKeyName].ConnectionDetails?.password))

    clusterIssuerCredentials: res.K8sObjectSecretWrapper {
        _name = "${_name}-cluster-issuer-credentials"
        _targetK8sProviderConfigName = _targetK8sProviderConfig.managedResource.metadata.name
        _stringData = {
            accessKeyId = _accessKeyId
            accessKeySecret = _accessKeySecret
        }
        _targetNamespace = "cert-manager"
    }
    clusterIssuer: res.K8sObjectGenericWrapper {
        _name = "${_name}-cluster-issuer"
        _targetK8sProviderConfigName = _targetK8sProviderConfig.managedResource.metadata.name
        managedResource.spec.forProvider.manifest = {
            apiVersion = "cert-manager.io/v1"
            kind = "ClusterIssuer"
            metadata.name = "letsencrypt"
            spec.acme = {
                server = "https://acme-v02.api.letsencrypt.org/directory"
                # ToDo: hard coded email
                email = "jasper.z@posteo.de"
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
    managedResources: [res.ManagedResource] = [
        awsUser.managedResource
        awsAccessKey.managedResource
        awsPolicy.managedResource
        awsUserPolicyAttachment.managedResource
        helmRepo.managedResource
        helmRelease.managedResource
        clusterIssuerCredentials.managedResource
        clusterIssuer.managedResource
    ]

    usages: [res.Usage] = awsUser.usages + awsAccessKey.usages + awsPolicy.usages + awsUserPolicyAttachment.usages + helmRepo.usages + helmRelease.usages + clusterIssuerCredentials.usages + clusterIssuer.usages

