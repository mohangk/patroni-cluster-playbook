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
#

locals {
  cluster_name = "pg-cluster" #move to var
}

resource "google_compute_disk" "pg_disk" {
  for_each = toset(var.zones)
  name     = "pg-disk-${index(var.zones, each.value) + 1}"
  type     = "pd-ssd"
  zone     = each.key
}

resource "google_compute_instance" "pg" {
  for_each = toset(var.zones)
  name         = "pg-${index(var.zones, each.value) + 1}"
  machine_type = "n2-standard-2" #TODO: Move to var
  zone = each.key

  tags = ["pg-patroni"]
  labels = {
    cluster = local.cluster_name
  }

  metadata = {
    CLUSTER_NAME  = local.cluster_name
    ETCD_ILB_FQDN = "10.10.0.11:2379" #TODO: Move to var (and find out if there is a way to refer to this from the etcd setup 
    REPLICATION_HOSTS_CIDR = google_compute_subnetwork.subnet.ip_cidr_range
  }

  metadata_startup_script = file("../scripts/pg/bootstrap-pg.sh")

  boot_disk {
    initialize_params {
      image = "pg13-202102031140" #TODO: Move to var
      size = "10"
      type = "pd-standard"
    }
  }

  attached_disk {
          source      = google_compute_disk.pg_disk[each.key].id
          device_name = "data"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
  }

  service_account {
    scopes = ["compute-ro", "service-control","service-management", "logging-write", "monitoring-write", "storage-ro"]
  }
}

#resource "google_compute_instance_group" "etcd" {
#  name        = "etcd-${each.key}-ig"
#  description = "Unamanged instance groups that contain the etcd instances"
#  for_each = toset(var.zones)
#
#  instances = [google_compute_instance.etcd-instances[each.key].id]
#  
#
#  zone = each.key
#}
#
#locals {
#  health_check = {
#    type                = "http"
#    check_interval_sec  = 1
#    healthy_threshold   = 4
#    timeout_sec         = 1
#    unhealthy_threshold = 5
#    response            = ""
#    proxy_header        = "NONE"
#    port                = 2379
#    port_name           = "health-check-port"
#    request             = ""
#    request_path        = "/health"
#    host                = "1.2.3.4"
#  }
#}
#
#
#module "etcd-ilb" {
#  source       = "GoogleCloudPlatform/lb-internal/google"
#  version      = "~> 2.0"
#  region       = var.region
#  network      = google_compute_network.vpc.name
#  subnetwork   = google_compute_subnetwork.subnet.name
#  name         = "etcd-ilb"
#  ports        = ["2379"]
#  health_check = local.health_check
#  source_ip_ranges  = ["0.0.0.0/0"]
#  source_tags = ["client"]
#  target_tags  = ["etcd"]
#  backends     = [
#    { group = google_compute_instance_group.etcd["us-central1-a"].self_link, description = "zone a ig" },
#    { group = google_compute_instance_group.etcd["us-central1-b"].self_link, description = "zone b ig" },
#    { group = google_compute_instance_group.etcd["us-central1-c"].self_link, description = "zone c ig" },
#  ]
#}
