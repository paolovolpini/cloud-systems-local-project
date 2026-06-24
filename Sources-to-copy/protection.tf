resource "gitea_repository_branch_protection" "local_infra_prot" {
    name = gitea_repository.local_infra.name
    username = var.gitea_username
    rule_name = "main"
    required_approvals = 0
    enable_push = false
    status_check_patterns = ["plan"]
}