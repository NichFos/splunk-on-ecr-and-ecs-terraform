resource "aws_ecr_repository" "splunk_repo" {
  name                 = "class6/splunk"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}
