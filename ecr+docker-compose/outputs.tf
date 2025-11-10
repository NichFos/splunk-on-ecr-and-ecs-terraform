output "ecr-repo-url" {
  value = aws_ecr_repository.splunk_repo.repository_url
}