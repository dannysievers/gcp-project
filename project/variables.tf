variable "project_name" {}
variable "billing_account" {}
variable "org_id" {}

variable "region" {
  default = "us-central1"
}

variable "gcp_services" {
  type = list(string)
}