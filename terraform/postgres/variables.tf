# Variables for postgres

variable "gce_image" {
  default =  "ubuntu-1604-xenial-v20181023"
  description = "GCE image name"
}

variable "gce_zone" {
  description = "Run the gce Instances in these Availability Zones"
  default = "europe-west1-b"
}

variable "machine_type" {
  default = "n1-highcpu-2"
  description = "cockroach instance machine type"
}