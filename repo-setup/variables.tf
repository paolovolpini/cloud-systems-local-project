variable "gitea_username" {
    type = string 
    default = "pablo"
}

variable "gitea_url" {
    type = string 
    default = "http://localhost:3000/"
}

variable "gitea_token" {
    type = string 
    default = "./gitea_token"
    description = "The 'gitea_token' variable is a path to the app token and not the actual content of the file"
}

variable "ssh_private_key" {
    type = string 
    default = "./ssh_id"
    description = "The 'ssh_private_key' variable is a path to the key and not the actual content of the file"
}

variable "ssh_public_key" {
    type = string 
    default = "./ssh_id.pub"
    description = "The 'ssh_public_key' variable is a path to the key and not the actual content of the file"
}

variable "postgre_secret" {
    type = string
    default = "./postgre-pass.txt"
}