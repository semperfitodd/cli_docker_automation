module "cli_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.13.0"

  bucket                                = local.environment
  attach_deny_insecure_transport_policy = true
  block_public_acls                     = true
  block_public_policy                   = true
  force_destroy                         = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}