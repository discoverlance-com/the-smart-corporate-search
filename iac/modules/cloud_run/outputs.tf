output "service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_v2_service.service.name
}

output "service_uri" {
  description = "The main URI of the Cloud Run service"
  value       = google_cloud_run_v2_service.service.uri
}

output "service_urls" {
  description = "All URLs serving traffic for the Cloud Run service"
  value       = google_cloud_run_v2_service.service.urls
}

output "service_id" {
  description = "The fully qualified service ID"
  value       = google_cloud_run_v2_service.service.id
}

output "latest_ready_revision" {
  description = "Name of the latest revision that is serving traffic"
  value       = google_cloud_run_v2_service.service.latest_ready_revision
}

output "latest_created_revision" {
  description = "Name of the last created revision"
  value       = google_cloud_run_v2_service.service.latest_created_revision
}

output "invoker_members" {
  description = "List of members granted Cloud Run invoker access"
  value       = var.invoker_members
}
