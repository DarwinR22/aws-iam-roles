# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# MCI-EventBridge-DeploymentABAC Policy Module - Following ABAC Pattern
# Converted from definitions/policies/deployment/MCI-EventBridge-DeploymentABAC.yaml
resource "aws_iam_policy" "main" {
  name        = "mci-mci-eventbridge-deploymentabac"
  path        = "/policies/"
  description = var.policy_description

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EventBridgeFullManagement"
        Effect   = "Allow"
        Action   = ["events:PutRule", "events:DeleteRule", "events:DescribeRule", "events:EnableRule", "events:DisableRule", "events:ListRules", "events:PutTargets", "events:RemoveTargets", "events:ListTargetsByRule", "events:PutEvents", "events:TagResource", "events:UntagResource", "events:ListTagsForResource"]
        Resource = ["arn:aws:events:*:*:rule/*"]
        Condition = {
        StringEquals = { "aws:RequestTag/gerencia" = ["$${aws:PrincipalTag/gerencia}"] } }
        }, {
        Sid      = "EventBridgeSchedulerManagement"
        Effect   = "Allow"
        Action   = ["scheduler:CreateSchedule", "scheduler:DeleteSchedule", "scheduler:GetSchedule", "scheduler:UpdateSchedule", "scheduler:ListSchedules", "scheduler:CreateScheduleGroup", "scheduler:DeleteScheduleGroup", "scheduler:GetScheduleGroup", "scheduler:ListScheduleGroups", "scheduler:TagResource", "scheduler:UntagResource"]
        Resource = ["arn:aws:scheduler:*:*:schedule/*", "arn:aws:scheduler:*:*:schedule-group/*"]
        }, {
        Sid      = "StepFunctionsFullManagement"
        Effect   = "Allow"
        Action   = ["states:CreateStateMachine", "states:DeleteStateMachine", "states:UpdateStateMachine", "states:DescribeStateMachine", "states:ListStateMachines", "states:StartExecution", "states:StopExecution", "states:DescribeExecution", "states:GetExecutionHistory", "states:ListExecutions", "states:TagResource", "states:UntagResource", "states:ListTagsForResource"]
        Resource = ["arn:aws:states:*:*:stateMachine:*", "arn:aws:states:*:*:execution:*:*"]
        Condition = {
        StringEquals = { "aws:RequestTag/gerencia" = ["$${aws:PrincipalTag/gerencia}"] } }
        }, {
        Sid      = "StepFunctionsActivityManagement"
        Effect   = "Allow"
        Action   = ["states:CreateActivity", "states:DeleteActivity", "states:DescribeActivity", "states:GetActivityTask", "states:ListActivities", "states:SendTaskSuccess", "states:SendTaskFailure", "states:SendTaskHeartbeat"]
        Resource = ["arn:aws:states:*:*:activity:*"]
    }]
  })

  tags = merge(var.common_tags, {
    Name = "mci-eventbridge-deploymentabac-${var.environment}"
    Type = "Policy"
  })
}