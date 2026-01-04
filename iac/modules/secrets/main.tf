resource "google_secret_manager_secret" "secrets" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.value.secret_id

  labels = merge(
    var.default_labels,
    each.value.labels
  )

  annotations = each.value.annotations

  # Use regional replication in us-central1
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  # Optional TTL configuration
  version_destroy_ttl = each.value.version_destroy_ttl

  # Prevent accidental deletion in production
  deletion_protection = each.value.deletion_protection

  # Optional expiration
  dynamic "rotation" {
    for_each = each.value.rotation != null ? [each.value.rotation] : []
    content {
      next_rotation_time = rotation.value.next_rotation_time
      rotation_period    = rotation.value.rotation_period
    }
  }
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
