# サービスで使用するECR
## ap-northeast-1
resource "aws_ecr_repository" "myecr" {
  name                 = "${var.sys_name}-${var.env_name}-${var.subsys_name}-repo"
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "KMS"

  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_lifecycle_policy" "myecr_policy" {
  repository = aws_ecr_repository.myecr.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only one untagged image, expire all others",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
