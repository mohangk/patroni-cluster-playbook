resource "google_compute_instance" "pg-img-vm" {
  name         = "pg-img2"
  machine_type = "n2-standard-2"

  tags = ["pg-img-vm", "image"]
  labels = {
    pgimage = "true"
  }


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
