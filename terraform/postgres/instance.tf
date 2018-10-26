
resource "google_compute_firewall" "default" {
  name    = "postgres-firewall"
  network = "default"
  allow {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "postgres" {
  // Adjust as desired
  name  = "postgres"
  // yields "test1", "test2", etc. It's also the machine's name and hostname
  machine_type = "${var.machine_type}"
  // smallest (CPU &amp; RAM) available instance
  zone  =  "${var.gce_zone}"
  // yields "europe-west1-d" as setup previously. Places your VM in Europe

  boot_disk {
    initialize_params {
      image = "${var.gce_image}"
    }
  }
  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP - leaving this block empty will generate a new external IP and assign it to the machine
    }
  }
}
resource "null_resource" "cluster" {
  depends_on = ["google_compute_instance.postgres"]
  provisioner "local-exec" {
    command = <<EOT
      sleep 40;
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --u $USER --private-key ~/.ssh/google_compute_engine -i /usr/local/Cellar/terraform-inventory/0.6.1/bin/terraform-inventory  ../ansible/install-postgres.yml --extra-vars "ansible_sudo_pass=0205"
    EOT
  }
}
