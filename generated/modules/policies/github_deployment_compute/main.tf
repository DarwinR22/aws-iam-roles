# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-compute Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/github-deployment-compute.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-compute"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "VPCManagement"
        Effect   = "Allow"
        Action   = ["ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute", "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute", "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags"]
        Resource = ["arn:aws:ec2:*:*:vpc/*"]
        }, {
        Sid      = "InternetGatewayManagement"
        Effect   = "Allow"
        Action   = ["ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways"]
        Resource = ["arn:aws:ec2:*:*:internet-gateway/*", "arn:aws:ec2:*:*:vpc/*"]
        }, {
        Sid      = "SubnetManagement"
        Effect   = "Allow"
        Action   = ["ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute", "ec2:DescribeSubnets", "ec2:DescribeAvailabilityZones"]
        Resource = ["arn:aws:ec2:*:*:subnet/*", "arn:aws:ec2:*:*:vpc/*"]
        }, {
        Sid      = "SecurityGroupManagement"
        Effect   = "Allow"
        Action   = ["ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress", "ec2:DescribeSecurityGroups", "ec2:DescribeSecurityGroupRules"]
        Resource = ["arn:aws:ec2:*:*:security-group/*", "arn:aws:ec2:*:*:vpc/*"]
        }, {
        Sid      = "RouteTableManagement"
        Effect   = "Allow"
        Action   = ["ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:ReplaceRoute", "ec2:DescribeRouteTables"]
        Resource = ["arn:aws:ec2:*:*:route-table/*", "arn:aws:ec2:*:*:subnet/*", "arn:aws:ec2:*:*:vpc/*", "arn:aws:ec2:*:*:internet-gateway/*", "arn:aws:ec2:*:*:nat-gateway/*"]
        }, {
        Sid      = "NATGatewayManagement"
        Effect   = "Allow"
        Action   = ["ec2:CreateNatGateway", "ec2:DeleteNatGateway", "ec2:DescribeNatGateways", "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses"]
        Resource = ["arn:aws:ec2:*:*:nat-gateway/*", "arn:aws:ec2:*:*:subnet/*", "arn:aws:ec2:*:*:elastic-ip/*"]
        }, {
        Sid      = "EC2InstanceManagement"
        Effect   = "Allow"
        Action   = ["ec2:RunInstances", "ec2:TerminateInstances", "ec2:StopInstances", "ec2:StartInstances", "ec2:RebootInstances", "ec2:DescribeInstances", "ec2:DescribeInstanceStatus", "ec2:DescribeInstanceAttribute", "ec2:ModifyInstanceAttribute", "ec2:DescribeInstanceTypes", "ec2:GetConsoleOutput", "ec2:GetPasswordData", "ec2:MonitorInstances", "ec2:UnmonitorInstances", "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags"]
        Resource = ["*"]
        }, {
        Sid      = "EC2LaunchTemplatesAndAMI"
        Effect   = "Allow"
        Action   = ["ec2:CreateLaunchTemplate", "ec2:CreateLaunchTemplateVersion", "ec2:DeleteLaunchTemplate", "ec2:DeleteLaunchTemplateVersions", "ec2:DescribeLaunchTemplates", "ec2:DescribeLaunchTemplateVersions", "ec2:ModifyLaunchTemplate", "ec2:DescribeImages", "ec2:DescribeImageAttribute", "ec2:CreateKeyPair", "ec2:DeleteKeyPair", "ec2:DescribeKeyPairs", "ec2:ImportKeyPair"]
        Resource = ["*"]
        }, {
        Sid      = "LoadBalancerManagement"
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:DeleteLoadBalancer", "elasticloadbalancing:DescribeLoadBalancers", "elasticloadbalancing:DescribeLoadBalancerAttributes", "elasticloadbalancing:ModifyLoadBalancerAttributes", "elasticloadbalancing:CreateTargetGroup", "elasticloadbalancing:DeleteTargetGroup", "elasticloadbalancing:DescribeTargetGroups", "elasticloadbalancing:DescribeTargetGroupAttributes", "elasticloadbalancing:ModifyTargetGroup", "elasticloadbalancing:ModifyTargetGroupAttributes", "elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets", "elasticloadbalancing:DescribeTargetHealth", "elasticloadbalancing:CreateListener", "elasticloadbalancing:DeleteListener", "elasticloadbalancing:DescribeListeners", "elasticloadbalancing:ModifyListener", "elasticloadbalancing:CreateRule", "elasticloadbalancing:DeleteRule", "elasticloadbalancing:DescribeRules", "elasticloadbalancing:ModifyRule", "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags", "elasticloadbalancing:DescribeTags"]
        Resource = ["*"]
        }, {
        Sid      = "AutoScalingManagement"
        Effect   = "Allow"
        Action   = ["autoscaling:CreateAutoScalingGroup", "autoscaling:DeleteAutoScalingGroup", "autoscaling:DescribeAutoScalingGroups", "autoscaling:UpdateAutoScalingGroup", "autoscaling:SetDesiredCapacity", "autoscaling:TerminateInstanceInAutoScalingGroup", "autoscaling:CreateLaunchConfiguration", "autoscaling:DeleteLaunchConfiguration", "autoscaling:DescribeLaunchConfigurations", "autoscaling:PutScalingPolicy", "autoscaling:DeletePolicy", "autoscaling:DescribePolicies", "autoscaling:ExecutePolicy", "autoscaling:PutLifecycleHook", "autoscaling:DeleteLifecycleHook", "autoscaling:DescribeLifecycleHooks", "autoscaling:CompleteLifecycleAction", "autoscaling:CreateOrUpdateTags", "autoscaling:DeleteTags", "autoscaling:DescribeTags", "autoscaling:PutNotificationConfiguration", "autoscaling:DeleteNotificationConfiguration", "autoscaling:DescribeNotificationConfigurations"]
        Resource = ["*"]
        }, {
        Sid      = "ApplicationAutoScalingManagement"
        Effect   = "Allow"
        Action   = ["application-autoscaling:RegisterScalableTarget", "application-autoscaling:DeregisterScalableTarget", "application-autoscaling:DescribeScalableTargets", "application-autoscaling:PutScalingPolicy", "application-autoscaling:DeleteScalingPolicy", "application-autoscaling:DescribeScalingPolicies", "application-autoscaling:DescribeScalingActivities"]
        Resource = ["*"]
        }, {
        Sid      = "VPCFlowLogs"
        Effect   = "Allow"
        Action   = ["ec2:CreateFlowLogs", "ec2:DeleteFlowLogs", "ec2:DescribeFlowLogs", "logs:CreateLogGroup", "logs:DescribeLogGroups", "logs:PutRetentionPolicy"]
        Resource = ["arn:aws:ec2:*:*:vpc/*", "arn:aws:ec2:*:*:network-interface/*", "arn:aws:ec2:*:*:subnet/*", "arn:aws:logs:*:*:log-group:*"]
        }, {
        Sid      = "EC2ReadOnlyAccess"
        Effect   = "Allow"
        Action   = ["ec2:DescribeRegions", "ec2:DescribeAccountAttributes", "ec2:DescribeVpcEndpoints", "ec2:DescribeNetworkAcls", "ec2:DescribeVpcClassicLink", "ec2:DescribeVpcClassicLinkDnsSupport"]
        Resource = ["*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-compute-${var.environment}"
    Type = "Policy"
  })
}