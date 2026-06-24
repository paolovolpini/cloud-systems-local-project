variable "cpu_num" {
    type = number
    default = 2
}

variable "ram" {
    type = string 
    default = "2G"
}

variable "disk" {
    type = string
    default = "10G"
}

variable "image" {
    type = string
    default = "lts"
}

variable "worker_count" {
    type = number
    default = 2
}

variable "control_plane_count" {
    type = number
    default = 1
}

variable "ssh_public_key" {
    type = string 
    default = "./ssh_id.pub"
    description = "The 'ssh_public_key' variable is a path to the key and not the actual content of the file"
}
