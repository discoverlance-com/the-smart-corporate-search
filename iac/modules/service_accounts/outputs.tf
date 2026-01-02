output "service_account_id" {
  description = "The unique ID of the service account"
  value       = google_service_account.service_account.unique_id
}

output "service_account_email" {
  description = "The email address of the service account"
  value       = google_service_account.service_account.email
}

output "service_account_name" {
  description = "The fully-qualified name of the service account"
  value       = google_service_account.service_account.name
}

output "service_account_member" {
  description = "The Identity of the service account in the form serviceAccount:{email}"
  value       = google_service_account.service_account.member
}
