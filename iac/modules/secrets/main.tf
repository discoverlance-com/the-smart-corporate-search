resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.value.secret_id

  labels = merge(
    var.default_labels,
    each.value.labels
  )

  # Use regional replication in us-central1
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  # Prevent accidental deletion in production
  deletion_protection = each.value.deletion_protection
}

# Grant secret accessor role to specified service accounts
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  for_each = {
    for combination in local.secret_accessor_combinations : "${combination.secret_key}_${combination.member}" => combination
  }

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.value.secret_key].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value.member
}

# Local to create all combinations of secrets and their accessor members
locals {
  secret_accessor_combinations = flatten([
    for secret_key, secret_config in var.secrets : [
      for member in secret_config.accessor_members : {
        secret_key = secret_key
        member     = member
      }
    ]
  ])
}
