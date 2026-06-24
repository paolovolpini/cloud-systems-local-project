terraform {
    required_providers {
      gitea = {
        source = "go-gitea/gitea"
        version = "~>0.7.0"
      }
    }
}

# Nota: senza "insecure: true" il provider proverà a usare TLS
# visto che è self-hosted e senza alcun certificato, bisogna specificare la modalità non sicura

provider "gitea" {
    base_url = var.gitea_url
    token = trimspace(file(var.gitea_token))
    insecure = true
}

resource "gitea_repository" "application" {
    name = "shortener-application"
    username = var.gitea_username
    issue_labels = "Default"
    private = false
}

resource "gitea_repository_actions_secret" "ssh_private_key_app" {
    repository = gitea_repository.application.name
    repository_owner = gitea_repository.application.username
    secret_name = "SSH_PRIVATE_KEY"
    secret_value = trimspace(file(var.ssh_private_key))
}

resource "gitea_repository_actions_secret" "ssh_public_key_app" {
    repository = gitea_repository.application.name
    repository_owner = gitea_repository.application.username
    secret_name = "SSH_PUBLIC_KEY"
    secret_value = trimspace(file(var.ssh_public_key))
}

resource "gitea_repository" "local_infra" {
    name = "local-infrastructure"
    username = var.gitea_username
    issue_labels = "Default"
    private = false
}

resource "gitea_repository_actions_secret" "ssh_private_key_infra" {
    repository = gitea_repository.local_infra.name
    repository_owner = gitea_repository.local_infra.username
    secret_name = "SSH_PRIVATE_KEY"
    secret_value = trimspace(file(var.ssh_private_key))
}

resource "gitea_repository_actions_secret" "ssh_public_key_infra" {
    repository = gitea_repository.local_infra.name
    repository_owner = gitea_repository.local_infra.username
    secret_name = "SSH_PUBLIC_KEY"
    secret_value = trimspace(file(var.ssh_public_key))
}

resource "gitea_repository_actions_secret" "postgre_secret" {
    repository = gitea_repository.local_infra.name
    repository_owner = gitea_repository.local_infra.username
    secret_name = "POSTGRE_SECRET"
    secret_value = trimspace(file(var.postgre_secret))
}
