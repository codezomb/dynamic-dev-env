resource "aws_kms_key" "key" {
  description         = "${var.prefix}-development-key"
  enable_key_rotation = true
  multi_region        = true
}
