variable "region" {
  default = "us-central1"
  description = "The region of the instance(s) databases"
}

variable "region_zone" {
  default = "us-central1-f"
  description = "The zone of the instance(s) databases"
}

variable "project_name" {
  description = "The ID of the Google Cloud project"
}

variable "account_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
}
