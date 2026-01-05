resource "google_project_service" "apis" {
  for_each = toset(var.apis)

  project = var.project_id
  service = each.value

  disable_dependent_services = var.disable_dependent_services

  disable_on_destroy = var.disable_on_destroy
}
