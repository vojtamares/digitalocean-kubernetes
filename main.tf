resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = "fra1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.18.8-do.0"
  tags    = ["test"]

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

resource "digitalocean_loadbalancer" "lb" {
  name   = "b"
  region = "fra1"

  droplet_tag = "k8s:${digitalocean_kubernetes_cluster.k8s.id}"

  healthcheck {
    port     = 30001
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 80
    target_port     = 30001
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 443
    target_port     = 30002
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 8080
    target_port     = 30003
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  sensitive = true
}

output "lb_ip" {
  value = digitalocean_loadbalancer.lb.ip
}
