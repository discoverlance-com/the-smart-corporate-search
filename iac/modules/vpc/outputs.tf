output "network_id" {
  description = "The unique identifier for the network"
  value       = google_compute_network.vpc_network.network_id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "network_self_link" {
  description = "The URI of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "gateway_ipv4" {
  description = "The gateway address for default routing out of the network"
  value       = google_compute_network.vpc_network.gateway_ipv4
}

output "subnets" {
  description = "Map of created subnets"
  value = {
    for key, subnet in google_compute_subnetwork.subnets : key => {
      id              = subnet.id
      name            = subnet.name
      ip_cidr_range   = subnet.ip_cidr_range
      region          = subnet.region
      self_link       = subnet.self_link
      gateway_address = subnet.gateway_address
    }
  }
}
