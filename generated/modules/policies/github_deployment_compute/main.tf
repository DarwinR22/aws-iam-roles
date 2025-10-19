# Auto-generated policy module: github_deployment_compute

resource "aws_iam_policy" "github_deployment_compute" {
  name        = "${var.environment}-github-deployment-compute"
  description = "Política consolidada para recursos de cómputo (EC2, ALB, Auto Scaling) del SGSI Layer 3"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcAttribute",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags"
        ],
        "Sid" : "VPCManagement",
        "Resource" : [
          "arn:aws:ec2:*:*:vpc/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DescribeInternetGateways"
        ],
        "Sid" : "InternetGatewayManagement",
        "Resource" : [
          "arn:aws:ec2:*:*:internet-gateway/*",
          "arn:aws:ec2:*:*:vpc/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSubnet",
          "ec2:DeleteSubnet",
          "ec2:ModifySubnetAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeAvailabilityZones"
        ],
        "Sid" : "SubnetManagement",
        "Resource" : [
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:ec2:*:*:vpc/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules"
        ],
        "Sid" : "SecurityGroupManagement",
        "Resource" : [
          "arn:aws:ec2:*:*:security-group/*",
          "arn:aws:ec2:*:*:vpc/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:ReplaceRoute",
          "ec2:DescribeRouteTables"
        ],
        "Sid" : "RouteTableManagement",
        "Resource" : [
          "arn:aws:ec2:*:*:route-table/*",
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:ec2:*:*:vpc/*",
          "arn:aws:ec2:*:*:internet-gateway/*",
          "arn:aws:ec2:*:*:nat-gateway/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:DescribeNatGateways",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:DescribeAddresses"
        ],
        "Sid" : "NATGatewayManagement",
        "Resource" : [
          "arn:aws:ec2:*:*:nat-gateway/*",
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:ec2:*:*:elastic-ip/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:RebootInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeInstanceTypes",
          "ec2:GetConsoleOutput",
          "ec2:GetPasswordData",
          "ec2:MonitorInstances",
          "ec2:UnmonitorInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags"
        ],
        "Sid" : "EC2InstanceManagement",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          },
          "StringLike" : {
            "ec2:InstanceProfile" : [
              "arn:aws:iam::*:instance-profile/sgsi-*",
              "arn:aws:iam::*:instance-profile/mci-*"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:DeleteLaunchTemplate",
          "ec2:DeleteLaunchTemplateVersions",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:ModifyLaunchTemplate",
          "ec2:DescribeImages",
          "ec2:DescribeImageAttribute",
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair",
          "ec2:DescribeKeyPairs",
          "ec2:ImportKeyPair"
        ],
        "Sid" : "EC2LaunchTemplatesAndAMI",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:DescribeTags"
        ],
        "Sid" : "LoadBalancerManagement",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:CreateLaunchConfiguration",
          "autoscaling:DeleteLaunchConfiguration",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:PutScalingPolicy",
          "autoscaling:DeletePolicy",
          "autoscaling:DescribePolicies",
          "autoscaling:ExecutePolicy",
          "autoscaling:PutLifecycleHook",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:CreateOrUpdateTags",
          "autoscaling:DeleteTags",
          "autoscaling:DescribeTags",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:DeleteNotificationConfiguration",
          "autoscaling:DescribeNotificationConfigurations"
        ],
        "Sid" : "AutoScalingManagement",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "application-autoscaling:RegisterScalableTarget",
          "application-autoscaling:DeregisterScalableTarget",
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:PutScalingPolicy",
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:DescribeScalingActivities"
        ],
        "Sid" : "ApplicationAutoScalingManagement",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateFlowLogs",
          "ec2:DeleteFlowLogs",
          "ec2:DescribeFlowLogs",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy"
        ],
        "Sid" : "VPCFlowLogs",
        "Resource" : [
          "arn:aws:ec2:*:*:vpc/*",
          "arn:aws:ec2:*:*:network-interface/*",
          "arn:aws:ec2:*:*:subnet/*",
          "arn:aws:logs:*:*:log-group:*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeRegions",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeVpcClassicLink",
          "ec2:DescribeVpcClassicLinkDnsSupport"
        ],
        "Sid" : "EC2ReadOnlyAccess",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestedRegion" : "us-east-1"
          }
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name          = "${var.environment}-github-deployment-compute"
      PolicyType    = "Custom"
      Scope         = "Service"
      GeneratedFrom = "github_deployment_compute.yaml"
    }
  )
}
