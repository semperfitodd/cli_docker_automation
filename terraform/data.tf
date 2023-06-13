data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "aws_availability_zones" "this" {}

data "aws_caller_identity" "this" {}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "code" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "code_policy" {
  statement {
    actions   = ["autoscaling:StartInstanceRefresh"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["codecommit:GitPull"]
    effect    = "Allow"
    resources = ["arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:${aws_codecommit_repository.this.repository_name}"]
  }
  statement {
    actions   = ["codepipeline:StartPipelineExecution"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    effect    = "Allow"
    resources = ["arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.this.account_id}:report-group/${aws_codecommit_repository.this.repository_name}-*"]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["iam:GetInstanceProfile"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["ec2:*"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = ["route53:*"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "acm:ListCertificates",
      "acm:ImportCertificate",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ec2_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ec2_s3_access" {
  statement {
    effect = "Allow"
    resources = [
      module.cli_s3.s3_bucket_arn,
      "${module.cli_s3.s3_bucket_arn}/*"
    ]
    actions = ["*"]
  }
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["codepipeline.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "pipeline_policy" {
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    effect    = "Allow"
    condition {
      test = "StringEqualsIfExists"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
      variable = "iam:PassedToService"
    }
  }
  statement {
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "opsworks:CreateDeployment",
      "opsworks:DescribeApps",
      "opsworks:DescribeCommands",
      "opsworks:DescribeDeployments",
      "opsworks:DescribeInstances",
      "opsworks:DescribeStacks",
      "opsworks:UpdateApp",
      "opsworks:UpdateStack",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    effect = "Allow"
    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct",
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["cloudformation:ValidateTemplate"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ecr:DescribeImages"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment",
    ]
    resources = ["*"]
  }
}

data "aws_region" "current" {}