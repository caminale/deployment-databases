# GCE zone to use.


resource "google_compute_instance" "cockroach" {
  count = "${var.number_instances}"
  // Adjust as desired
  name  = "cockroach${count.index + 1}"
  // yields "test1", "test2", etc. It's also the machine's name and hostname
  machine_type = "${var.machine_type}"
  // smallest (CPU &amp; RAM) available instance
  zone  =  "${element(var.gce_zone_list,ceil(count.index / var.factor_number))}"
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

resource "google_compute_firewall" "default" {
  name    = "cockroach-firewall"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["8080", "26257", "5222"]
  }
  target_tags   = ["cockroachdb"]
  source_ranges = ["0.0.0.0/0", "35.187.63.1","35.233.122.229", "35.205.220.0/22"]
}

resource "google_compute_instance_group" "cockroach_crew" {
  count       = "${var.number_groups}"
  name        = "terraform-cockroach-crew${count.index +1}"
  description = "Terraform test cockroach instance group"
  zone        = "${element(var.gce_zone_list, count.index)}"
  named_port {
    name = "tcp26257"
    port = 26257
  }
  instances = [
    "${slice(google_compute_instance.cockroach.*.self_link, count.index * var.factor_number,  (count.index + 1) * var.factor_number)}"
  ]
}

resource "google_compute_health_check" "health-node" {
  name               = "cockroach-health-check-tcp"
  timeout_sec        = 1
  check_interval_sec = 1
  http_health_check  {
    port = 8080
    request_path = "/health?ready=1"
  }
}

resource "google_compute_backend_service" "cockroach-service" {
  name          = "cockroach-backend-service"
  description   = "terraform backend"
  port_name   = "${google_compute_instance_group.cockroach_crew.0.named_port.0.name}"
  protocol      = "TCP"
  health_checks = ["${google_compute_health_check.health-node.self_link}"]
  timeout_sec   = 10

//  backend = ["${data.template_file.service_json.rendered}"]

  backend {
    group = "${google_compute_instance_group.cockroach_crew.0.self_link}"
  }
//  backend {
//    group = "${google_compute_instance_group.cockroach_crew.1.self_link}"
//  }
//  backend {
//    group = "${google_compute_instance_group.cockroach_crew.2.self_link}"
//  }

}

resource "google_compute_global_address" "ipv-4" {
  name       = "ipv-4"
}

resource "google_compute_target_tcp_proxy" "default" {
  name            = "tcp-proxy-lb-cockroach"
  description     = "test"
  backend_service = "${google_compute_backend_service.cockroach-service.self_link}"
}

resource "google_compute_global_forwarding_rule" "USA" {
  name       = "forwarding-rule-usa-lb"
  ip_address = "${google_compute_global_address.ipv-4.address}"
  target     = "${google_compute_target_tcp_proxy.default.self_link}"
  port_range = "5222"
}

resource "null_resource" "cluster" {
  depends_on = ["google_compute_backend_service.cockroach-service"]
  provisioner "local-exec" {
    command = <<EOT
      sleep 80;
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --u $USER --private-key ~/.ssh/google_compute_engine -i /usr/local/Cellar/terraform-inventory/0.6.1/bin/terraform-inventory   ../ansible/install-cockroachdb.yml
    EOT
  }
}
