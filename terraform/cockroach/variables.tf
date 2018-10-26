# Variables for cockroach cluster

variable "number_instances" {
  default = 3
}

variable "factor_number" {
  default = 3
  description = "Number of instances by group"
}

variable "number_groups" {
  default = 1
  description = "Number of groups into the cluster = regions' number"
}

variable "gce_zone_list" {
  description = "Run the gce Instances in these Availability Zones, if number_groups=3 you will have these 3 zones"
  type = "list"
  default = [ "europe-west1-b","europe-west2-a", "europe-west3-a"]
}

variable "gce_image" {
  default =  "ubuntu-1404-trusty-v20180423"
  description = "GCE image name"
}

variable "machine_type" {
  default = "n1-highcpu-2"
  description = "cockroach instance machine type"
}