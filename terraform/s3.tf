# --------------------------------------------------------------------------------
# Development Storage Bucket
# --------------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "dev-storage" {
  bucket = aws_s3_bucket.dev-storage.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "dev-storage" {
  bucket = "${var.prefix}-development-bucket"
}
