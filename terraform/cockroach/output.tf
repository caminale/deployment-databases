output "ip" {
  value = "${google_compute_instance.cockroach.0.network_interface.0.access_config.0.assigned_nat_ip}"
}
output "ip2" {
  value = "${google_compute_instance.cockroach.0.network_interface.0.access_config}"
}

