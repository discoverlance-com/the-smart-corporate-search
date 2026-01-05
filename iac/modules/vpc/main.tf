resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  description             = var.description
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  name                     = each.value.name
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = google_compute_network.vpc_network.id
  region                   = each.value.region
  description              = each.value.description
  project                  = var.project_id
  private_ip_google_access = each.value.private_ip_google_access

  depends_on = [google_compute_network.vpc_network]
}
