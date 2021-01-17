#
#
# instance -> zonal unmanaged ig -> backend service + hc -> fwd rule
#
# the ilb modules handles creating
# - backend service, 
# - fwd rule
# - firewalls
# - backends service hc
#
//https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager
resource "google_compute_instance" "etcd-instances" {
  for_each = toset(var.zones)
  name         = "etcd-${each.key}"
  machine_type = "n2-standard-2"
  zone = each.key

  tags = ["etcd"]


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
      size = "10"
      type = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
  }

  service_account {
    scopes = ["compute-ro", "service-control","service-management", "logging-write", "monitoring-write", "storage-ro"]
  }
}

resource "google_compute_instance_group" "etcd" {
  name        = "etcd-${each.key}-ig"
  description = "Unamanged instance groups that contain the etcd instances"
  for_each = toset(var.zones)

  instances = [google_compute_instance.etcd-instances[each.key].id]
  

  zone = each.key
}

locals {
  health_check = {
    type                = "http"
    check_interval_sec  = 1
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 80
    port_name           = "health-check-port"
    request             = ""
    request_path        = "/"
    host                = "1.2.3.4"
  }
}


module "etcd-ilb" {
  source       = "GoogleCloudPlatform/lb-internal/google"
  version      = "~> 2.0"
  region       = var.region
  network      = google_compute_network.vpc.name
  subnetwork   = google_compute_subnetwork.subnet.name
  name         = "etcd-ilb"
  ports        = ["80"]
  health_check = local.health_check
  source_ip_ranges  = ["0.0.0.0/0"]
  source_tags = ["client"]
  target_tags  = ["etcd"]
  backends     = [
    { group = google_compute_instance_group.etcd["us-central1-a"].self_link, description = "zone a ig" },
    { group = google_compute_instance_group.etcd["us-central1-b"].self_link, description = "zone b ig" },
    { group = google_compute_instance_group.etcd["us-central1-c"].self_link, description = "zone c ig" },
  ]
}
