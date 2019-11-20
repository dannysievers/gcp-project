resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}

resource "google_project" "project" {
  name            = "var.project_name"
  project_id      = "random_id.id.hex"
  billing_account = "var.billing_account_id"
  org_id          = "var.org_id"
}

resource "google_project_service" "project" {
  count = length(var.gcp_services)
  project = "google_project.project.project_id"
  services = "var.gcp_services[count.index]"
}