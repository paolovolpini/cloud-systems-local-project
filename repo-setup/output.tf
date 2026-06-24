output "git_commands" {
    description = "Clone the repositories with the URLs"
    value = [gitea_repository.application.clone_url, gitea_repository.local_infra.clone_url][*]
}