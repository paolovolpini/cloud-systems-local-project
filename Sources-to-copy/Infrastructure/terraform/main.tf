resource "local_file" "cloudinit" {
    filename = pathexpand("~/tofu-gen/cloud-init.yaml")
    content = templatefile("${path.module}/cloud-init.tftpl", {
        pubkey = trimspace(file(var.ssh_public_key))
    })
}

resource "multipass_instance" "workers" {
    count = var.worker_count

    name = "worker${count.index+1}"
    cpus = var.cpu_num
    memory = var.ram
    disk = var.disk
    image = var.image
    cloudinit_file = local_file.cloudinit.filename
}


resource "multipass_instance" "control_plane" {
    name = "control-plane"
    cpus = var.cpu_num
    memory = var.ram
    disk = var.disk
    image = var.image
    cloudinit_file = local_file.cloudinit.filename
}

resource "multipass_instance" "registry" {
    name = "registry"
    cpus = var.cpu_num
    memory = var.ram
    disk = var.disk
    image = var.image
    cloudinit_file = local_file.cloudinit.filename
}

resource "multipass_instance" "load_balancer" {
    name = "load-balancer"
    cpus = 1
    memory = "1G"
    disk = "5G"
    image = var.image
    cloudinit_file = local_file.cloudinit.filename
}

resource "local_file" "lb_cfg" {
    filename = pathexpand("~/tofu-gen/haproxy.cfg")
    content = templatefile("${path.module}/haproxy.tftpl", {
        w_ips = multipass_instance.workers[*].ipv4
    })
}

resource "local_file" "hosts" {
    filename = pathexpand("~/tofu-gen/hosts.ini")
    content = templatefile("${path.module}/hosts.tftpl", {
        workers_ip = multipass_instance.workers[*].ipv4
        cp_ip = multipass_instance.control_plane.ipv4
        privkey = "./terraform/ssh_id"
        reg_ip = multipass_instance.registry.ipv4
        lb_ip = multipass_instance.load_balancer.ipv4
    })
}

resource "local_file" "containerd_cert" {
    filename = pathexpand("~/tofu-gen/hosts-containerd.toml")
    content = templatefile("${path.module}/hosts-containerd.tftpl", {
        reg_ip = multipass_instance.registry.ipv4
    })
}

resource "local_file" "daemon_docker" {
    filename = pathexpand("~/tofu-gen/daemon.json")
    content = templatefile("${path.module}/daemon.tftpl", {
        reg_ip = multipass_instance.registry.ipv4
    })
}