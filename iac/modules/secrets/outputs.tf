output "secrets" {
  description = "Map of created secrets with their details"
  value = {
    for secret_key, secret in google_secret_manager_secret.secrets : secret_key => {
      secret_id        = secret.secret_id
      name             = secret.name
      id               = secret.id
      create_time      = secret.create_time
      effective_labels = secret.effective_labels
    }
  }
}

output "secret_names" {
  description = "Map of secret keys to their full resource names"
  value = {
    for secret_key, secret in google_secret_manager_secret.secrets : secret_key => secret.name
  }
}

output "secret_ids" {
  description = "Map of secret keys to their secret IDs"
  value = {
    for secret_key, secret in google_secret_manager_secret.secrets : secret_key => secret.secret_id
  }
}
