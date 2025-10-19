# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# github-deployment-ec2 Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment\github-deployment-ec2.yaml
resource "aws_iam_policy" "main" {
  name        = "github-deployment-ec2"
  path        = "/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
Sid    = "VPCManagement"
Effect = "Allow"
        Action = ["ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute", "ec2:DescribeVpcs", "ec2:DescribeVpcAttribute", "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags"]
        Resource = [          "arn:aws:ec2:*:*:vpc/*"        ]
      },      {
Sid    = "InternetGatewayManagement"
Effect = "Allow"
        Action = ["ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways"]
        Resource = [          "arn:aws:ec2:*:*:internet-gateway/*",          "arn:aws:ec2:*:*:vpc/*"        ]
      },      {
Sid    = "SubnetManagement"
Effect = "Allow"
        Action = ["ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute", "ec2:DescribeSubnets", "ec2:DescribeAvailabilityZones"]
        Resource = [          "arn:aws:ec2:*:*:subnet/*",          "arn:aws:ec2:*:*:vpc/*"        ]
      },      {
Sid    = "SecurityGroupManagement"
Effect = "Allow"
        Action = ["ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress", "ec2:DescribeSecurityGroups", "ec2:DescribeSecurityGroupRules"]
        Resource = [          "arn:aws:ec2:*:*:security-group/*",          "arn:aws:ec2:*:*:vpc/*"        ]
      },      {
Sid    = "RouteTableManagement"
Effect = "Allow"
        Action = ["ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:ReplaceRoute", "ec2:DescribeRouteTables"]
        Resource = [          "arn:aws:ec2:*:*:route-table/*",          "arn:aws:ec2:*:*:subnet/*",          "arn:aws:ec2:*:*:vpc/*",          "arn:aws:ec2:*:*:internet-gateway/*",          "arn:aws:ec2:*:*:nat-gateway/*"        ]
      },      {
Sid    = "NATGatewayManagement"
Effect = "Allow"
        Action = ["ec2:CreateNatGateway", "ec2:DeleteNatGateway", "ec2:DescribeNatGateways", "ec2:AllocateAddress", "ec2:ReleaseAddress", "ec2:DescribeAddresses"]
        Resource = [          "arn:aws:ec2:*:*:nat-gateway/*",          "arn:aws:ec2:*:*:subnet/*",          "arn:aws:ec2:*:*:elastic-ip/*"        ]
      },      {
Sid    = "VPCFlowLogs"
Effect = "Allow"
        Action = ["ec2:CreateFlowLogs", "ec2:DeleteFlowLogs", "ec2:DescribeFlowLogs", "logs:CreateLogGroup", "logs:DescribeLogGroups", "logs:PutRetentionPolicy"]
        Resource = [          "arn:aws:ec2:*:*:vpc/*",          "arn:aws:ec2:*:*:network-interface/*",          "arn:aws:ec2:*:*:subnet/*",          "arn:aws:logs:*:*:log-group:*"        ]
      },      {
Sid    = "EC2ReadOnlyAccess"
Effect = "Allow"
        Action = ["ec2:DescribeRegions", "ec2:DescribeAccountAttributes", "ec2:DescribeVpcEndpoints", "ec2:DescribeNetworkAcls", "ec2:DescribeVpcClassicLink", "ec2:DescribeVpcClassicLinkDnsSupport"]
        Resource = [          "*"        ]
      }    ]
  })

  tags = merge(var.common_tags, {
    Name = "github-deployment-ec2-${var.environment}"
    Type = "Policy"
  })
}