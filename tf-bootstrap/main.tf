module "s3_bucket" {
  source                  = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.10.1"
  bucket                  = "terraform-state"
  block_public_acls       = "true"
  block_public_policy     = "true"
  ignore_public_acls      = "true"
  restrict_public_buckets = "true"
  attach_policy           = "true"
  versioning = {
    enabled = true
  }
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            ]
          },
          "Action" : [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : [
            "${module.s3_bucket.s3_bucket_arn}",
            "${module.s3_bucket.s3_bucket_arn}/*"
          ]
        }
      ]
  })
}

module "dynamodb_table" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table.git//?ref=v3.3.0"

  name           = "terraform-lock-table"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attributes = [
    {
      name = "LockID"
      type = "S"
  }]

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
  billing_mode = "PROVISIONED"
}
