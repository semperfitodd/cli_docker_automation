module "codepipeline_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.13.0"

  bucket                                = "${local.environment}-codepipeline"
  attach_deny_insecure_transport_policy = true
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true
  force_destroy                         = true
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id                                     = "cleanup"
      enabled                                = "true"
      abort_incomplete_multipart_upload_days = 7

      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = [
        {
          days = 30
        }
      ]
    }
  ]

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.environment}_codebuild_log_group"
  retention_in_days = 3

  tags = var.tags
}

resource "aws_codebuild_project" "this" {
  name        = aws_codecommit_repository.this.repository_name
  description = "codebuild project for ${aws_codecommit_repository.this.repository_name}"

  vpc_config {
    vpc_id = module.vpc.vpc_id

    subnets = module.vpc.private_subnets

    security_group_ids = [aws_security_group.code.id]
  }

  concurrent_build_limit = 1
  build_timeout          = "45"
  service_role           = aws_iam_role.code.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_VERSION"
      value = "1.3.0"
    }
    environment_variable {
      name  = "PKR_VERSION"
      value = "1.8.3"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.this.name
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.us-east-2.amazonaws.com/v1/repos/${aws_codecommit_repository.this.repository_name}"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "refs/heads/master"

  tags = var.tags
}

resource "aws_codecommit_repository" "this" {
  repository_name = var.environment
  description     = "Repository holding code for ${var.environment}"

  tags = var.tags
}

resource "aws_codepipeline" "this" {
  name     = "${var.environment}_pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = module.codepipeline_s3.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category         = "Source"
      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"

      configuration = {
        BranchName           = "master"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = false
        RepositoryName       = aws_codecommit_repository.this.repository_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      category         = "Build"
      input_artifacts  = ["SourceArtifact"]
      name             = "Build"
      output_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"

      configuration = {
        ProjectName = var.environment
      }
    }
  }

  tags = var.tags

  depends_on = [module.codepipeline_s3]
}

resource "aws_iam_policy" "code" {
  name = "${var.environment}_codebuild_policy"

  policy = data.aws_iam_policy_document.code_policy.json
}

resource "aws_iam_policy" "pipeline" {
  name = "${var.environment}_codepipeline_policy"

  policy = data.aws_iam_policy_document.pipeline_policy.json
}

resource "aws_iam_role" "code" {
  name = "codebuild_${var.environment}_service_role"

  assume_role_policy = data.aws_iam_policy_document.code.json

  tags = var.tags
}

resource "aws_iam_role" "pipeline" {
  name = "codepipeline_${var.environment}_service_role"

  assume_role_policy = data.aws_iam_policy_document.pipeline.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "code" {
  role       = aws_iam_role.code.name
  policy_arn = aws_iam_policy.code.arn
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.pipeline.arn
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.code.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_security_group" "code" {
  name        = "codebuild"
  description = "Security group attached to codebuild instances"
  vpc_id      = module.vpc.vpc_id
  tags = merge(
    var.tags,
    { Name = "codebuild" }
  )
}

resource "aws_security_group_rule" "code_egress" {
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.code.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
