resource "aws_iam_instance_profile" "developer-env" {
  role = aws_iam_role.developer-env.name
  name = "${var.prefix}-development"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.developer-env.id
}

resource "aws_iam_role_policy" "developer-env" {
  role = aws_iam_role.developer-env.id

  policy = templatefile("./policies/instance.json", {
    s3_bucket = aws_s3_bucket.dev-storage.arn
    kms_key   = aws_kms_key.key.arn
  })
}

resource "aws_iam_role" "developer-env" {
  assume_role_policy = file("./policies/assume-role.json")
  name               = "${var.prefix}-development-role"
}
