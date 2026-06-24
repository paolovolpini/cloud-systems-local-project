output "registry_ip" {
    value = multipass_instance.registry.ipv4
    description = "IP of registry"
}

output "docker_command" {
    value = "Copy the contents of ~/tofu-gen/daemon.json in /etc/docker/daemon.json and restart docker service"
} 

output "load_balancer_ip" {
    description = "Connect to service via lb IP"
    value = multipass_instance.load_balancer.ipv4
}