#trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "terraform_state" {
  bucket_prefix = "tmp-hands-on-terraform-state-"
  lifecycle {
    prevent_destroy = true
  }
}

#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_sse" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_public_access_block" "terraform_state_access_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_life_cycle" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.terraform_state_versioning]

  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    id = "oldVersionRule"

    noncurrent_version_expiration {
      noncurrent_days           = 1
      newer_noncurrent_versions = 3
    }
    status = "Enabled"
  }
}

#trivy:ignore:AVD-AWS-0024
#trivy:ignore:AVD-AWS-0025
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "tmp-hands-on-terraform-state-lock-"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
